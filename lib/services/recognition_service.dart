import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' show Size;

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image/image.dart' as img;

import '../config/api_config.dart';

class RecognitionResponse {
  RecognitionResponse({
    required this.prediction,
    required this.accuracy,
    required this.processingTimeMs,
    this.imageUrl,
    this.pipeline,
  });

  final String prediction;
  final double accuracy;
  final int processingTimeMs;
  final String? imageUrl;
  final RecognitionPipeline? pipeline;

  factory RecognitionResponse.fromJson(Map<String, dynamic> json) {
    return RecognitionResponse(
      prediction: json['prediction']?.toString() ?? '---',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      processingTimeMs: json['processing_time_ms'] ?? 0,
      imageUrl: json['image_url']?.toString(),
      pipeline: json['pipeline'] is Map<String, dynamic>
          ? RecognitionPipeline.fromJson(
              json['pipeline'] as Map<String, dynamic>,
            )
          : null,
    );
  }
}

class RecognitionPipeline {
  RecognitionPipeline({
    required this.stages,
    required this.digitCrops,
    required this.summary,
  });

  final List<PipelineStage> stages;
  final List<DigitCropVisual> digitCrops;
  final PipelineSummary summary;

  bool get hasVisuals => stages.isNotEmpty || digitCrops.isNotEmpty;

  factory RecognitionPipeline.fromJson(Map<String, dynamic> json) {
    final List<PipelineStage> stageList = [];
    final rawStages = json['stages'];
    if (rawStages is List) {
      for (final entry in rawStages) {
        if (entry is Map<String, dynamic>) {
          stageList.add(PipelineStage.fromJson(entry));
        }
      }
    }

    final List<DigitCropVisual> cropList = [];
    final rawCrops = json['digit_crops'];
    if (rawCrops is List) {
      for (final entry in rawCrops) {
        if (entry is Map<String, dynamic>) {
          cropList.add(DigitCropVisual.fromJson(entry));
        }
      }
    }

    return RecognitionPipeline(
      stages: stageList,
      digitCrops: cropList,
      summary: PipelineSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class PipelineStage {
  PipelineStage({
    required this.key,
    required this.title,
    required this.description,
    required this.imageBytes,
    this.naturalSize,
  });

  final String key;
  final String title;
  final String description;
  final Uint8List imageBytes;
  final Size? naturalSize;

  double? get aspectRatio {
    final size = naturalSize;
    if (size == null || size.width <= 0 || size.height <= 0) {
      return null;
    }
    return size.width / size.height;
  }

  factory PipelineStage.fromJson(Map<String, dynamic> json) {
    final bytes = _decodeBase64Image(json['image']?.toString());
    Size? intrinsicSize;
    if (bytes.isNotEmpty) {
      final decoded = img.decodeImage(bytes);
      if (decoded != null && decoded.width > 0 && decoded.height > 0) {
        intrinsicSize = Size(
          decoded.width.toDouble(),
          decoded.height.toDouble(),
        );
      }
    }

    return PipelineStage(
      key: json['key']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageBytes: bytes,
      naturalSize: intrinsicSize,
    );
  }
}

class DigitCropVisual {
  DigitCropVisual({
    required this.index,
    required this.label,
    required this.confidence,
    required this.imageBytes,
  });

  final int index;
  final String label;
  final double confidence;
  final Uint8List imageBytes;

  String get caption => 'Digit ${index + 1}: $label';

  factory DigitCropVisual.fromJson(Map<String, dynamic> json) {
    return DigitCropVisual(
      index: json['index'] is int
          ? json['index'] as int
          : int.tryParse(json['index']?.toString() ?? '0') ?? 0,
      label: json['label']?.toString() ?? '-',
      confidence: (json['confidence'] ?? 0).toDouble(),
      imageBytes: _decodeBase64Image(json['image']?.toString()),
    );
  }
}

class PipelineSummary {
  const PipelineSummary({
    required this.prediction,
    required this.accuracy,
    required this.processingTimeMs,
    required this.digitCount,
  });

  final String prediction;
  final double accuracy;
  final int processingTimeMs;
  final int digitCount;

  factory PipelineSummary.fromJson(Map<String, dynamic> json) {
    return PipelineSummary(
      prediction: json['prediction']?.toString() ?? '-',
      accuracy: (json['accuracy'] ?? 0).toDouble(),
      processingTimeMs: json['processing_time_ms'] is int
          ? json['processing_time_ms'] as int
          : int.tryParse(json['processing_time_ms']?.toString() ?? '0') ?? 0,
      digitCount: json['digit_count'] is int
          ? json['digit_count'] as int
          : int.tryParse(json['digit_count']?.toString() ?? '0') ?? 0,
    );
  }
}

Uint8List _decodeBase64Image(String? payload) {
  if (payload == null || payload.isEmpty) {
    return Uint8List(0);
  }
  try {
    return base64Decode(payload);
  } catch (_) {
    return Uint8List(0);
  }
}

class RecognitionException implements Exception {
  RecognitionException(this.message);

  final String message;

  @override
  String toString() => 'RecognitionException(message: $message)';
}

class RecognitionService {
  static const int _maxUploadBytes = 4 * 1024 * 1024; // 4MB guard

  RecognitionService({Dio? dio})
    : _dio =
          dio ??
          Dio(
            BaseOptions(
              baseUrl: ApiConfig.recognitionBaseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 10),
            ),
          );

  final Dio _dio;

  Future<RecognitionResponse> submit({
    required Uint8List imageBytes,
    required String captureSource,
    Map<String, dynamic>? cropBox,
    String? deviceId,
  }) async {
    _validateFileSize(imageBytes.lengthInBytes);

    try {
      final fileName = 'capture_${DateTime.now().millisecondsSinceEpoch}.jpg';

      final formData = FormData.fromMap({
        'device_id': deviceId ?? 'frontend-simulator',
        'capture_source': captureSource,
        'timestamp': DateTime.now().toIso8601String(),
        if (cropBox != null) 'crop_box': jsonEncode(cropBox),
        'image': MultipartFile.fromBytes(
          imageBytes,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post('/recognitions', data: formData);
      return RecognitionResponse.fromJson(
        response.data as Map<String, dynamic>,
      );
    } on DioException catch (error) {
      throw RecognitionException(_mapDioError(error));
    } catch (error) {
      throw RecognitionException(error.toString());
    }
  }

  String _mapDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
        return 'Tidak dapat terhubung ke server. Pastikan backend sedang berjalan.';
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Permintaan timeout. Mohon coba lagi.';
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode ?? 0;
        final detail = _extractDetail(error.response?.data);
        if (status >= 500) {
          return 'Server mengalami gangguan. Coba lagi nanti.';
        }
        return detail ?? 'Permintaan ditolak (kode $status).';
      case DioExceptionType.cancel:
        return 'Permintaan dibatalkan.';
      case DioExceptionType.badCertificate:
        return 'Sertifikat server tidak valid.';
    }
  }

  String? _extractDetail(dynamic data) {
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return null;
  }

  void _validateFileSize(int size) {
    if (size == 0) {
      throw RecognitionException('Gambar tidak boleh kosong.');
    }
    if (size > _maxUploadBytes) {
      final sizeMb = (size / (1024 * 1024)).toStringAsFixed(1);
      final maxMb = (_maxUploadBytes / (1024 * 1024)).toStringAsFixed(1);
      throw RecognitionException(
        'Ukuran file $sizeMb MB melebihi batas $maxMb MB. Mohon perkecil gambar.',
      );
    }
  }
}
