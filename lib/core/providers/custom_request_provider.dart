import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../services/custom_request_service.dart';

class CustomRequestProvider extends ChangeNotifier {
  CustomRequestProvider(this._service);
  final CustomRequestService _service;

  bool isSubmitting = false;
  String? lastRequestId;
  String? imageUrl;
  String? error;

  Future<bool> submit({required String shape, required String flavor, required String weight, String? theme, String? message, Uint8List? imageBytes, String? filename}) async {
    isSubmitting = true;
    error = null;
    notifyListeners();
    try {
      final id = await _service.create(shape: shape, flavor: flavor, weight: weight, theme: theme, message: message);
      lastRequestId = id;
      if (imageBytes != null && filename != null) {
        imageUrl = await _service.uploadImage(requestId: id, bytes: imageBytes, filename: filename);
      }
      return true;
    } catch (e) {
      error = 'Submission failed';
      return false;
    } finally {
      isSubmitting = false;
      notifyListeners();
    }
  }
}


