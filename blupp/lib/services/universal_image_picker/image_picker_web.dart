// ignore: avoid_web_libraries_in_flutter
import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'universal_image_picker.dart';

Future<UniversalPickedImage?> pickImageNativeOrWeb({
  required bool isCamera,
}) async {
  final completer = Completer<UniversalPickedImage?>();

  try {
    final uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    if (isCamera) {
      uploadInput.setAttribute('capture', 'environment');
    }

    // CRITICAL FIX FOR SAFARI ON IOS:
    // Elements MUST be attached to the DOM for Safari to allow programmatic .click()
    uploadInput.style.position = 'fixed';
    uploadInput.style.left = '-9999px';
    uploadInput.style.top = '-9999px';
    uploadInput.style.opacity = '0';
    html.document.body!.append(uploadInput);

    uploadInput.onChange.listen((e) async {
      try {
        final files = uploadInput.files;
        if (files == null || files.isEmpty) {
          uploadInput.remove();
          if (!completer.isCompleted) completer.complete(null);
          return;
        }

        final file = files[0];
        final reader = html.FileReader();
        reader.readAsArrayBuffer(file);
        await reader.onLoadEnd.first;

        final rawResult = reader.result;
        Uint8List bytes;
        if (rawResult is Uint8List) {
          bytes = rawResult;
        } else if (rawResult is List<int>) {
          bytes = Uint8List.fromList(rawResult);
        } else if (rawResult is ByteBuffer) {
          bytes = rawResult.asUint8List();
        } else {
          bytes = Uint8List.fromList((rawResult as dynamic) as List<int>);
        }

        final blobUrl = html.Url.createObjectUrlFromBlob(file);
        final base64Str = base64Encode(bytes);

        uploadInput.remove();
        if (!completer.isCompleted) {
          completer.complete(UniversalPickedImage(
            bytes: bytes,
            name: file.name,
            path: blobUrl,
            base64String: base64Str,
          ));
        }
      } catch (err) {
        debugPrint('[ImagePickerWeb] Error reading file: $err');
        uploadInput.remove();
        if (!completer.isCompleted) completer.complete(null);
      }
    });

    // Also handle user cancel / window focus return
    html.window.addEventListener('focus', (event) {
      Future.delayed(const Duration(milliseconds: 1200), () {
        if (!completer.isCompleted) {
          uploadInput.remove();
          completer.complete(null);
        }
      });
    }, true);

    // Trigger click synchronously
    uploadInput.click();
  } catch (e) {
    debugPrint('[ImagePickerWeb] Error launching file picker: $e');
    if (!completer.isCompleted) completer.complete(null);
  }

  return completer.future;
}
