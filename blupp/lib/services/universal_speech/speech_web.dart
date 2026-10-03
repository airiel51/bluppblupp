// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'universal_speech.dart';

html.SpeechRecognition? _recognition;
bool _isListening = false;

bool isSpeechSupported() {
  try {
    return html.SpeechRecognition.supported;
  } catch (_) {
    return false;
  }
}

void startListening({
  required SpeechTextCallback onResult,
  required SpeechStatusCallback onStatus,
}) {
  try {
    if (!html.SpeechRecognition.supported) {
      onStatus(false, "Speech recognition is not supported in this browser.");
      return;
    }

    _recognition = html.SpeechRecognition();
    _recognition!.continuous = false;
    _recognition!.interimResults = true;
    _recognition!.lang = 'en-MY';

    _recognition!.onStart.listen((event) {
      _isListening = true;
      onStatus(true, null);
    });

    _recognition!.onResult.listen((html.SpeechRecognitionEvent event) {
      final results = event.results;
      if (results != null && results.isNotEmpty) {
        String transcript = '';
        bool isFinal = false;
        for (final res in results) {
          final len = res.length ?? 0;
          if (len > 0) {
            final item = res.item(0);
            transcript += item.transcript ?? '';
            if (res.isFinal == true) {
              isFinal = true;
            }
          }
        }
        onResult(transcript.trim(), isFinal);
      }
    });

    _recognition!.onError.listen((event) {
      _isListening = false;
      onStatus(false, "Microphone access unavailable or denied.");
    });

    _recognition!.onEnd.listen((event) {
      _isListening = false;
      onStatus(false, null);
    });

    _recognition!.start();
  } catch (e) {
    _isListening = false;
    onStatus(false, e.toString());
  }
}

void stopListening() {
  try {
    if (_recognition != null && _isListening) {
      _recognition!.stop();
      _isListening = false;
    }
  } catch (_) {}
}
