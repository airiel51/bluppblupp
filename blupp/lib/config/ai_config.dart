/// Configuration for AI services in Blupp
class AiConfig {
  /// Default Google Gemini API key.
  /// Can be provided via `--dart-define=GEMINI_API_KEY=your_key` during build,
  /// or entered directly in the app UI via Settings / FOMO screen.
  static const String defaultGeminiApiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: '',
  );

  /// Primary Google Gemini model used for real-time impulse evaluation & chat
  static const String defaultModel = 'gemini-1.5-flash';

  /// Fallback models if primary model is unavailable or rate-limited
  static const List<String> fallbackModels = [
    'gemini-2.0-flash',
    'gemini-2.5-flash',
    'gemini-1.5-pro',
  ];

  /// Link where users can obtain a free Gemini API key
  static const String getApiKeyUrl = 'https://aistudio.google.com/app/apikey';
}
