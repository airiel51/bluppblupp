import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'universal_image_picker.dart';

Future<UniversalPickedImage?> pickImageNativeOrWeb({
  required bool isCamera,
}) async {
  try {
    final picker = ImagePicker();
    final XFile? file = await picker.pickImage(
      source: isCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1080,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (file == null) return null;
    final bytes = await file.readAsBytes();
    return UniversalPickedImage(
      bytes: bytes,
      name: file.name,
      path: file.path,
      base64String: base64Encode(bytes),
    );
  } catch (e) {
    debugPrint('[ImagePickerStub] Error picking image: $e');
    return null;
  }
}
