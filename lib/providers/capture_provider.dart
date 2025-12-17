import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import '../services/recognition_service.dart';

class CaptureProvider extends ChangeNotifier {
  Uint8List? _originalBytes;
  Uint8List? _croppedBytes;
  String? _prediction;
  double? _accuracy;
  bool _isUploading = false;
  String? _errorMessage;
  String? _captureSource;
  DateTime? _predictionTimestamp;
  RecognitionPipeline? _pipeline;
  String? _modelName;

  Uint8List? get originalBytes => _originalBytes;
  Uint8List? get croppedBytes => _croppedBytes;
  String? get prediction => _prediction;
  double? get accuracy => _accuracy;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;
  String? get captureSource => _captureSource;
  DateTime? get predictionTimestamp => _predictionTimestamp;
  RecognitionPipeline? get pipeline => _pipeline;
  String? get modelName => _modelName;

  void setOriginal(Uint8List bytes) {
    _originalBytes = bytes;
    notifyListeners();
  }

  void setCropped(Uint8List bytes) {
    _croppedBytes = bytes;
    notifyListeners();
  }

  void setPrediction(String value, double score) {
    _prediction = value;
    _accuracy = score;
    _predictionTimestamp = DateTime.now();
    notifyListeners();
  }

  void setCaptureSource(String source) {
    _captureSource = source;
    notifyListeners();
  }

  void setPipeline(RecognitionPipeline? pipeline) {
    _pipeline = pipeline;
    notifyListeners();
  }

  void setModelName(String? name) {
    _modelName = name;
    notifyListeners();
  }

  void setUploading(bool value) {
    _isUploading = value;
    notifyListeners();
  }

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clear() {
    _originalBytes = null;
    _croppedBytes = null;
    _prediction = null;
    _accuracy = null;
    _isUploading = false;
    _errorMessage = null;
    _captureSource = null;
    _predictionTimestamp = null;
    _pipeline = null;
    _modelName = null;
    notifyListeners();
  }
}
