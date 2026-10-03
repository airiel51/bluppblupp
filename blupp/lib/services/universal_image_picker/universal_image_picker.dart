import 'dart:typed_data';
import 'image_picker_stub.dart'
    if (dart.library.html) 'image_picker_web.dart' as platform;

class UniversalPickedImage {
  final Uint8List bytes;
  final String name;
  final String path;
  final String base64String;

  UniversalPickedImage({
    required this.bytes,
    required this.name,
    required this.path,
    required this.base64String,
  });
}

class UniversalImagePicker {
  /// Picks an image from Camera or Gallery with full Web (Safari iOS) and Native support.
  static Future<UniversalPickedImage?> pickImage({required bool isCamera}) {
    return platform.pickImageNativeOrWeb(isCamera: isCamera);
  }
}
