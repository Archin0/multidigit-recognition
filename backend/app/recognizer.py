from __future__ import annotations
import os
import time
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import List, Optional, Tuple
import base64

import cv2
import joblib
import numpy as np
from skimage.feature import hog


_MODELS_DIR = Path(__file__).parent.parent / "models"
_DEFAULT_SVM_MODEL = _MODELS_DIR / "svm_digit_classifier.joblib"
_DEFAULT_KNN_MODEL = _MODELS_DIR / "knn_digit_classifier.joblib"
_SVM_LABEL = "Support Vector Machine"
_KNN_LABEL = "K-Nearest Neighbors"


def _extract_pipeline_components(model_obj):
    """Return (estimator, scaler) if the stored model is an sklearn Pipeline."""
    named_steps = getattr(model_obj, "named_steps", None)
    steps = getattr(model_obj, "steps", None)
    if isinstance(named_steps, dict) and named_steps:
        scaler = named_steps.get("scaler")
        estimator = (
            named_steps.get("knn")
            or named_steps.get("svm")
            or named_steps.get("model")
            or list(named_steps.values())[-1]
        )
        return estimator, scaler
    if isinstance(steps, list) and steps:
        # fallback: assume first step is transformer, last step is estimator
        maybe_scaler = steps[0][1] if hasattr(steps[0][1], "transform") else None
        estimator = steps[-1][1]
        return estimator, maybe_scaler
    return model_obj, None


@dataclass
class DigitComponent:
    label: str
    confidence: float
    bbox: Tuple[int, int, int, int]

    def to_dict(self) -> dict:
        return asdict(self)


@dataclass
class RecognitionResult:
    prediction: str
    accuracy: float
    processing_time_ms: int
    digits: List[DigitComponent]
    pipeline: Optional[dict] = None
    model_name: Optional[str] = None

    def to_dict(self) -> dict:
        payload = {
            "prediction": self.prediction,
            "accuracy": self.accuracy,
            "processing_time_ms": self.processing_time_ms,
            "digits": [digit.to_dict() for digit in self.digits],
        }
        if self.pipeline is not None:
            payload["pipeline"] = self.pipeline
        if self.model_name is not None:
            payload["model_name"] = self.model_name
        return payload


class RecognitionError(Exception):
    """Raised when the recognition pipeline cannot infer a prediction."""


class DigitRecognizer:
    def __init__(self, model_path: Optional[str] = None, eager: bool = True):
        self._model = None
        self._scaler = None
        self._hog_params: Optional[dict] = None
        self._loaded_at: Optional[float] = None
        self._model_label: Optional[str] = None
        self.model_path = _DEFAULT_SVM_MODEL
        self.load_svm_model(model_path=model_path, eager=eager)

    @property
    def is_ready(self) -> bool:
        return self._model is not None and self._scaler is not None

    @property
    def last_loaded_at(self) -> Optional[str]:
        if self._loaded_at is None:
            return None
        return time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime(self._loaded_at))

    @property
    def model_label(self) -> str:
        return self._model_label or _SVM_LABEL

    def _switch_model(self, target_path: Path, eager: bool) -> None:
        resolved = Path(target_path)
        self.model_path = resolved
        self._model = None
        self._scaler = None
        self._hog_params = None
        self._loaded_at = None
        if eager:
            self.ensure_ready()

    def load_svm_model(self, model_path: Optional[str] = None, eager: bool = True) -> None:
        """Load the default SVM classifier artifact for the recognition pipeline."""
        default_path = _DEFAULT_SVM_MODEL
        resolved = Path(model_path or os.getenv("MODEL_PATH", default_path))
        self._model_label = _SVM_LABEL
        self._switch_model(resolved, eager)

    def load_knn_model(self, model_path: Optional[str] = None, eager: bool = True) -> None:
        """Load the alternative KNN classifier so predictions can use a different model."""
        default_path = _DEFAULT_KNN_MODEL
        resolved = Path(model_path or os.getenv("MODEL_PATH_KNN", default_path))
        self._model_label = _KNN_LABEL
        self._switch_model(resolved, eager)

    def ensure_ready(self) -> None:
        if self.is_ready:
            return
        if not self.model_path.exists():
            env_hint = "MODEL_PATH_KNN" if self.model_label == _KNN_LABEL else "MODEL_PATH"
            raise FileNotFoundError(
                f"Model artifact tidak ditemukan di {self.model_path}. "
                f"Set variabel lingkungan {env_hint} ke file .joblib yang benar.",
            )
        artifact = joblib.load(self.model_path)
        model_entry = artifact.get("model")
        scaler_entry = artifact.get("scaler")
        estimator, pipeline_scaler = _extract_pipeline_components(model_entry)
        if estimator is not None:
            self._model = estimator
            if scaler_entry is None and pipeline_scaler is not None:
                scaler_entry = pipeline_scaler
        else:
            self._model = None
        self._scaler = scaler_entry
        self._hog_params = artifact.get("hog_params")
        if self._model is None or self._scaler is None:
            raise RuntimeError(
                "File model tidak valid. Harus berisi key 'model' dan 'scaler'.",
            )
        self._loaded_at = time.time()

    def predict(self, image_bytes: bytes, expected_digits: Optional[int] = None) -> RecognitionResult:
        self.ensure_ready()
        np_buffer = np.frombuffer(image_bytes, dtype=np.uint8)
        image = cv2.imdecode(np_buffer, cv2.IMREAD_COLOR)
        if image is None:
            raise RecognitionError("Berkas gambar tidak dapat dibaca.")

        start = time.perf_counter()
        pipeline_output = _run_prediction_pipeline(
            image=image,
            expected_digits=expected_digits,
            model=self._model,
            scaler=self._scaler,
            hog_params=self._hog_params,
        )
        segments = pipeline_output["segments"]
        records = pipeline_output["records"]
        if not segments or not records:
            raise RecognitionError("Digit tidak terdeteksi pada gambar.")

        digit_components: List[DigitComponent] = []
        digit_payload: List[dict] = []
        prediction_chars: List[str] = []
        raw_confidences: List[float] = []

        for record in records:
            label_str = str(record["label"])
            confidence_pct = round(float(record["confidence"]) * 100.0, 2)
            digit_components.append(
                DigitComponent(
                    label=label_str,
                    confidence=confidence_pct,
                    bbox=record["bbox"],
                ),
            )
            prediction_chars.append(label_str)
            raw_confidences.append(float(record["confidence"]))
            digit_payload.append({
                "index": record["index"],
                "label": label_str,
                "confidence": confidence_pct,
                "image": _encode_png(_prepare_digit_debug_image(record["crop"])),
            })

        prediction = "".join(prediction_chars)
        accuracy = round(float(np.mean(raw_confidences) * 100.0), 2) if raw_confidences else 0.0
        processing_time_ms = int((time.perf_counter() - start) * 1000)
        preprocessed = pipeline_output["preprocessed"]
        mask = pipeline_output["mask"]
        best_overlay = _draw_overlay(preprocessed, segments)

        pipeline_steps = [
            {
                "key": "original",
                "title": "1. Foto Asli",
                "description": "Input yang diterima dari kamera atau galeri.",
                "image": _encode_png(pipeline_output["raw_bgr"]),
            },
            {
                "key": "preprocess",
                "title": "2. Preprocessing",
                "description": "Normalisasi kontras, CLAHE, dan balancing warna untuk menonjolkan digit.",
                "image": _encode_png(preprocessed),
            },
            {
                "key": "mask",
                "title": "3. Masking",
                "description": "Threshold adaptif untuk memisahkan digit dari latar belakang.",
                "image": _encode_png(cv2.cvtColor(mask, cv2.COLOR_GRAY2BGR)),
            },
            {
                "key": "segments",
                "title": "4. Segmentasi",
                "description": "Bounding box setiap digit serta urutan pembacaannya.",
                "image": _encode_png(best_overlay),
            },
        ]

        pipeline_payload = {
            "stages": pipeline_steps,
            "digit_crops": digit_payload,
            "summary": {
                "prediction": prediction,
                "accuracy": round(accuracy, 2),
                "processing_time_ms": processing_time_ms,
                "digit_count": len(digit_components),
                "contrast_std_dev": round(float(pipeline_output["std_dev"]), 2),
            },
        }

        return RecognitionResult(
            prediction=prediction,
            accuracy=round(accuracy, 2),
            processing_time_ms=processing_time_ms,
            digits=digit_components,
            pipeline=pipeline_payload,
            model_name=self.model_label,
        )

_DIGIT_CANVAS_SIZE = 28
_TARGET_DIGIT_EXTENT = 20
_MIN_SEGMENT_AREA = 80
_PROJECTION_PAD = 2
_BBOX_PAD = 2
_OWNERSHIP_MARGIN = 3
_DEFAULT_HOG_PARAMS = {
    "pixels_per_cell": (4, 4),
    "cells_per_block": (2, 2),
    "orientations": 9,
    "transform_sqrt": True,
    "block_norm": "L2-Hys",
}


def _ensure_foreground_white(img: np.ndarray) -> np.ndarray:
    return cv2.bitwise_not(img) if np.mean(img) > 127 else img


def _normalize_uint8(img: np.ndarray) -> np.ndarray:
    img = img.astype(np.float32)
    if img.max() > img.min():
        img = (img - img.min()) / (img.max() - img.min()) * 255.0
    return img.astype(np.uint8)


def _remove_background_variation(gray: np.ndarray) -> np.ndarray:
    kernel = cv2.getStructuringElement(cv2.MORPH_RECT, (25, 25))
    bg = cv2.morphologyEx(gray, cv2.MORPH_CLOSE, kernel)
    return cv2.subtract(bg, gray)


def _robust_preprocessing(image: np.ndarray) -> Tuple[np.ndarray, float]:
    if image is None:
        raise ValueError("Input image kosong")
    if image.ndim == 3:
        gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    else:
        gray = image.copy()

    blurred = cv2.GaussianBlur(gray, (3, 3), 0)
    normalized = _remove_background_variation(blurred)
    clahe = cv2.createCLAHE(clipLimit=2.5, tileGridSize=(8, 8))
    enhanced = clahe.apply(normalized)
    std_dev = float(np.std(enhanced))
    enhanced = _ensure_foreground_white(enhanced)
    return enhanced, std_dev


def _extract_hog(
    img: np.ndarray,
    hog_params: Optional[dict] = None,
) -> np.ndarray:
    if img.shape != (_DIGIT_CANVAS_SIZE, _DIGIT_CANVAS_SIZE):
        img = cv2.resize(img, (_DIGIT_CANVAS_SIZE, _DIGIT_CANVAS_SIZE), interpolation=cv2.INTER_AREA)
    params = {**_DEFAULT_HOG_PARAMS}
    if hog_params:
        params.update(hog_params)
    return hog(img, feature_vector=True, **params)


def _resize_and_center(
    img: np.ndarray,
    size: int = _DIGIT_CANVAS_SIZE,
    target_extent: int = _TARGET_DIGIT_EXTENT,
) -> np.ndarray:
    if img is None or img.size == 0:
        return np.zeros((size, size), dtype=np.uint8)
    if img.ndim == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = _normalize_uint8(img)
    img = _ensure_foreground_white(img)

    h, w = img.shape[:2]
    if h == 0 or w == 0:
        return np.zeros((size, size), dtype=np.uint8)
    scale = target_extent / max(h, w)
    new_w = max(1, int(round(w * scale)))
    new_h = max(1, int(round(h * scale)))
    interp = cv2.INTER_AREA if scale < 1 else cv2.INTER_CUBIC
    digit = cv2.resize(img, (new_w, new_h), interpolation=interp)

    canvas = np.zeros((size, size), dtype=np.uint8)
    y_off = (size - new_h) // 2
    x_off = (size - new_w) // 2
    canvas[y_off : y_off + new_h, x_off : x_off + new_w] = digit

    moments = cv2.moments(canvas)
    if abs(moments.get("m00", 0.0)) > 1e-6:
        cx = moments["m10"] / moments["m00"]
        cy = moments["m01"] / moments["m00"]
        shift_x = int(np.clip(size / 2 - cx, -size, size))
        shift_y = int(np.clip(size / 2 - cy, -size, size))
        shift_mat = np.float32([[1, 0, shift_x], [0, 1, shift_y]])
        canvas = cv2.warpAffine(canvas, shift_mat, (size, size), borderValue=0)

    return canvas


def _build_clean_mask(img_clean: np.ndarray) -> np.ndarray:
    blur = cv2.GaussianBlur(img_clean, (3, 3), 0)
    _, thresh = cv2.threshold(blur, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)
    kernel = np.ones((2, 2), np.uint8)
    clean = cv2.morphologyEx(thresh, cv2.MORPH_OPEN, kernel, iterations=1)
    return clean


def _build_ownership_mask(
    x0: int,
    y0: int,
    x1: int,
    y1: int,
    centroid: Tuple[float, float],
    other_centroids: List[Tuple[float, float]],
    margin_px: int = _OWNERSHIP_MARGIN,
) -> np.ndarray:
    h = max(0, y1 - y0)
    w = max(0, x1 - x0)
    if h == 0 or w == 0:
        return np.zeros((0, 0), dtype=np.uint8)
    if margin_px <= 0 or not other_centroids:
        return np.ones((h, w), dtype=np.uint8) * 255
    yy, xx = np.indices((h, w), dtype=np.float32)
    abs_x = xx + float(x0)
    abs_y = yy + float(y0)
    dx_cur = abs_x - float(centroid[0])
    dy_cur = abs_y - float(centroid[1])
    dist_cur = dx_cur * dx_cur + dy_cur * dy_cur
    dist_other = np.full_like(dist_cur, np.inf)
    for other in other_centroids:
        dx_o = abs_x - float(other[0])
        dy_o = abs_y - float(other[1])
        dist_other = np.minimum(dist_other, dx_o * dx_o + dy_o * dy_o)
    margin_sq = float(margin_px * margin_px)
    ownership = dist_cur <= (dist_other - margin_sq)
    return np.where(ownership, 255, 0).astype(np.uint8)


def _split_with_projection(
    mask: np.ndarray,
    img_clean: np.ndarray,
    expected_digits: int,
    min_area: int,
) -> List[dict]:
    if expected_digits <= 0:
        return []
    h, w = mask.shape
    col_profile = mask.sum(axis=0).astype(np.float32)
    if col_profile.max() <= 0:
        return []
    cumsum = np.cumsum(col_profile)
    total = cumsum[-1]
    cut_points = [0]
    for idx in range(1, expected_digits):
        target = total * idx / expected_digits
        cut_points.append(int(np.searchsorted(cumsum, target, side="left")))
    cut_points.append(w)
    for i in range(1, len(cut_points)):
        cut_points[i] = int(np.clip(cut_points[i], cut_points[i - 1] + 1e-3, w))

    digits: List[dict] = []
    for i in range(expected_digits):
        x0 = max(0, cut_points[i] - _PROJECTION_PAD)
        x1 = min(w, cut_points[i + 1] + _PROJECTION_PAD)
        if x1 <= x0:
            continue
        sub_mask = mask[:, x0:x1]
        ys, xs = np.where(sub_mask > 0)
        if len(xs) == 0:
            y_min, y_max = 0, h
            x_min, x_max = x0, x1
        else:
            y_min, y_max = int(ys.min()), int(ys.max() + 1)
            x_min, x_max = int(x0 + xs.min()), int(x0 + xs.max() + 1)
        if (x_max - x_min) * (y_max - y_min) < min_area:
            pad = _PROJECTION_PAD
            x_min = max(0, x_min - pad)
            x_max = min(w, x_max + pad)
            y_min = max(0, y_min - pad)
            y_max = min(h, y_max + pad)
        if _BBOX_PAD > 0:
            x_min = max(0, x_min - _BBOX_PAD)
            x_max = min(w, x_max + _BBOX_PAD)
            y_min = max(0, y_min - _BBOX_PAD)
            y_max = min(h, y_max + _BBOX_PAD)
        digit_patch = img_clean[y_min:y_max, x_min:x_max]
        crop = _resize_and_center(digit_patch)
        digits.append({
            "bbox": (x_min, y_min, x_max - x_min, y_max - y_min),
            "crop": crop,
        })
    return digits


def _ensure_bgr(image: np.ndarray) -> np.ndarray:
    if image is None:
        raise ValueError("Input image kosong")
    if image.ndim == 2:
        return cv2.cvtColor(image, cv2.COLOR_GRAY2BGR)
    if image.ndim == 3 and image.shape[2] == 4:
        return cv2.cvtColor(image, cv2.COLOR_BGRA2BGR)
    return image


def _run_prediction_pipeline(
    image: np.ndarray,
    expected_digits: Optional[int],
    model,
    scaler,
    hog_params: Optional[dict],
) -> dict:
    raw_bgr = _ensure_bgr(image)
    preprocessed, std_dev = _robust_preprocessing(raw_bgr)
    segments, mask = _segment_digits(preprocessed, expected_digits, min_area=_MIN_SEGMENT_AREA)
    records: List[dict] = []

    for idx, entry in enumerate(segments):
        crop = entry.get("crop")
        bbox = entry.get("bbox")
        if crop is None or bbox is None:
            continue
        features = _extract_hog(crop, hog_params=hog_params)
        scaled = scaler.transform(features.reshape(1, -1))
        scores = _decision_scores(model, scaled)
        if scores is not None:
            probs = _softmax(scores)
            pred_idx = int(np.argmax(probs))
            label_value = _resolve_label(model, pred_idx, len(probs))
            confidence = float(probs[pred_idx])
        else:
            label_value = int(model.predict(scaled)[0])
            confidence = 0.75
        records.append({
            "index": idx,
            "bbox": (int(bbox[0]), int(bbox[1]), int(bbox[2]), int(bbox[3])),
            "crop": crop,
            "label": label_value,
            "confidence": confidence,
        })

    return {
        "raw_bgr": raw_bgr,
        "preprocessed": preprocessed,
        "mask": mask,
        "std_dev": std_dev,
        "segments": segments,
        "records": records,
    }


def _segment_digits(
    img_clean: np.ndarray,
    expected_digits: Optional[int],
    min_area: int = _MIN_SEGMENT_AREA,
) -> Tuple[List[dict], np.ndarray]:
    clean_mask = _build_clean_mask(img_clean)
    contours, _ = cv2.findContours(clean_mask, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
    img_h, img_w = img_clean.shape[:2]
    contour_infos: List[dict] = []
    for contour in contours:
        x, y, w, h = cv2.boundingRect(contour)
        if w * h < min_area:
            continue
        moments = cv2.moments(contour)
        if abs(moments.get("m00", 0.0)) > 1e-6:
            cx = moments["m10"] / moments["m00"]
            cy = moments["m01"] / moments["m00"]
        else:
            cx = x + w / 2
            cy = y + h / 2
        contour_infos.append({
            "contour": contour,
            "bbox": (x, y, w, h),
            "centroid": (cx, cy),
        })

    contour_infos.sort(key=lambda info: info["bbox"][0])
    digits: List[dict] = []
    for info in contour_infos:
        contour = info["contour"]
        x, y, w, h = info["bbox"]
        x0 = max(0, x - _BBOX_PAD)
        y0 = max(0, y - _BBOX_PAD)
        x1 = min(img_w, x + w + _BBOX_PAD)
        y1 = min(img_h, y + h + _BBOX_PAD)
        digit_patch = img_clean[y0:y1, x0:x1]
        if digit_patch.size == 0:
            continue
        contour_mask = np.zeros_like(digit_patch, dtype=np.uint8)
        cv2.drawContours(contour_mask, [contour], -1, 255, thickness=cv2.FILLED, offset=(-x0, -y0))
        if contour_mask.max() == 0:
            continue
        others = [c["centroid"] for c in contour_infos if c is not info]
        if others and _OWNERSHIP_MARGIN > 0:
            ownership = _build_ownership_mask(x0, y0, x1, y1, info["centroid"], others)
            contour_mask = cv2.bitwise_and(contour_mask, ownership)
            if contour_mask.max() == 0:
                cv2.drawContours(contour_mask, [contour], -1, 255, thickness=cv2.FILLED, offset=(-x0, -y0))
        digit_patch = cv2.bitwise_and(digit_patch, digit_patch, mask=contour_mask)
        if digit_patch.max() == 0:
            digit_patch = img_clean[y0:y1, x0:x1]
        crop = _resize_and_center(digit_patch)
        digits.append({
            "bbox": (x0, y0, x1 - x0, y1 - y0),
            "crop": crop,
        })

    if expected_digits and expected_digits > 0 and len(digits) != expected_digits:
        projected = _split_with_projection(clean_mask, img_clean, expected_digits, min_area // 2)
        if projected:
            digits = projected

    digits.sort(key=lambda item: item.get("bbox", (0, 0, 0, 0))[0])
    return digits, clean_mask


def _draw_overlay(img_clean: np.ndarray, digits: List[dict]) -> np.ndarray:
    base = cv2.cvtColor(img_clean, cv2.COLOR_GRAY2BGR)
    for idx, entry in enumerate(digits):
        bbox = entry.get("bbox")
        if not bbox:
            continue
        x, y, w, h = bbox
        cv2.rectangle(base, (x, y), (x + w, y + h), (0, 200, 0), 2)
        cv2.putText(
            base,
            f"#{idx + 1}",
            (x, max(12, y - 6)),
            cv2.FONT_HERSHEY_SIMPLEX,
            0.6,
            (255, 230, 0),
            2,
            cv2.LINE_AA,
        )
    return base


def _prepare_digit_debug_image(crop: np.ndarray, scale: int = 4) -> np.ndarray:
    img = crop
    if img.ndim == 3:
        img = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    img = _normalize_uint8(img)
    height, width = img.shape[:2]
    return cv2.resize(img, (width * scale, height * scale), interpolation=cv2.INTER_NEAREST)


def _encode_png(image: np.ndarray) -> str:
    display = image
    if display.dtype != np.uint8:
        display = _normalize_uint8(display)
    success, buffer = cv2.imencode(".png", display)
    if not success:
        raise RuntimeError("Gagal melakukan encoding pipeline debug image")
    return base64.b64encode(buffer.tobytes()).decode("ascii")


def _decision_scores(model, sample: np.ndarray) -> Optional[np.ndarray]:
    if not hasattr(model, "decision_function"):
        return None
    scores = model.decision_function(sample)
    scores = np.asarray(scores, dtype=np.float64)
    if scores.ndim == 0:
        scores = scores.reshape(1)
    if scores.ndim > 1:
        scores = scores.ravel()
    return scores


def _softmax(scores: np.ndarray) -> np.ndarray:
    shifted = scores - np.max(scores)
    exp_scores = np.exp(shifted)
    denom = exp_scores.sum()
    if denom <= 0:
        return np.full_like(exp_scores, 1.0 / exp_scores.size)
    return exp_scores / denom


def _resolve_label(model, index: int, score_count: int):
    classes = getattr(model, "classes_", None)
    if classes is not None and len(classes) == score_count:
        return classes[index]
    return index
