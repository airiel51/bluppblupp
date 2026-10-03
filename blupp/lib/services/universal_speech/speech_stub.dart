import 'universal_speech.dart';

bool isSpeechSupported() => false;

void startListening({
  required SpeechTextCallback onResult,
  required SpeechStatusCallback onStatus,
}) {
  onStatus(false, "Voice recognition available on Web & mobile browsers.");
}

void stopListening() {}
