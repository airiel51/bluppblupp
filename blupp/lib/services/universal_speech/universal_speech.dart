import 'speech_stub.dart'
    if (dart.library.html) 'speech_web.dart' as platform;

typedef SpeechTextCallback = void Function(String text, bool isFinal);
typedef SpeechStatusCallback = void Function(bool isListening, String? error);

class UniversalSpeech {
  static bool get isSupported => platform.isSpeechSupported();

  static void startListening({
    required SpeechTextCallback onResult,
    required SpeechStatusCallback onStatus,
  }) {
    platform.startListening(onResult: onResult, onStatus: onStatus);
  }

  static void stopListening() {
    platform.stopListening();
  }
}
