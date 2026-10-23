import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../config/ai_config.dart';
import '../services/gemini_service.dart';
import '../theme/app_theme.dart';

class GeminiApiKeyDialog extends StatefulWidget {
  const GeminiApiKeyDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (ctx) => const GeminiApiKeyDialog(),
    );
  }

  @override
  State<GeminiApiKeyDialog> createState() => _GeminiApiKeyDialogState();
}

class _GeminiApiKeyDialogState extends State<GeminiApiKeyDialog> {
  final TextEditingController _keyController = TextEditingController();
  bool _obscureText = true;
  bool _isTesting = false;
  String? _statusFeedback;
  bool? _testSucceeded;
  late String _selectedModel;

  @override
  void initState() {
    super.initState();
    _keyController.text = GeminiService.instance.apiKey;
    final current = GeminiService.instance.selectedModel;
    if (!AiConfig.fallbackModels.contains(current) || current.isEmpty) {
      _selectedModel = AiConfig.defaultModel;
      GeminiService.instance.setModel(_selectedModel);
    } else {
      _selectedModel = current;
    }
  }

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _testAndSave() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) {
      setState(() {
        _statusFeedback = "Please enter an API key or tap 'Clear Key' to run in offline mode.";
        _testSucceeded = false;
      });
      return;
    }

    setState(() {
      _isTesting = true;
      _statusFeedback = null;
      _testSucceeded = null;
    });

    // Test the key live with Google Gemini
    final result = await GeminiService.instance.testApiKey(key);

    if (!mounted) return;

    if (result.success) {
      await GeminiService.instance.setApiKey(key);
      await GeminiService.instance.setModel(_selectedModel);
      setState(() {
        _isTesting = false;
        _statusFeedback = "Connected! Real AI is now active across Blupp FOMO.";
        _testSucceeded = true;
      });
    } else {
      setState(() {
        _isTesting = false;
        _statusFeedback = result.message;
        _testSucceeded = false;
      });
    }
  }

  Future<void> _clearKey() async {
    await GeminiService.instance.setApiKey('');
    if (!mounted) return;
    setState(() {
      _keyController.clear();
      _statusFeedback = "API Key removed. Running in offline rule-based mode.";
      _testSucceeded = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasActiveKey = GeminiService.instance.hasApiKey;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        decoration: BoxDecoration(
          color: const Color(0xFF131722),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: hasActiveKey ? AppTheme.primaryTeal.withValues(alpha: 0.3) : Colors.white12,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: hasActiveKey
                  ? AppTheme.primaryTeal.withValues(alpha: 0.15)
                  : Colors.black.withValues(alpha: 0.5),
              blurRadius: 32,
              spreadRadius: 4,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.fomoPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppTheme.fomoPurple.withValues(alpha: 0.3)),
                    ),
                    child: const Icon(
                      Icons.auto_awesome_rounded,
                      color: AppTheme.fomoPurple,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Google Gemini AI Engine",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: hasActiveKey ? const Color(0xFF10B981) : Colors.amber,
                                boxShadow: [
                                  BoxShadow(
                                    color: (hasActiveKey ? const Color(0xFF10B981) : Colors.amber)
                                        .withValues(alpha: 0.6),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              hasActiveKey ? "Real Gemini AI Connected" : "Offline Heuristic Mode",
                              style: TextStyle(
                                color: hasActiveKey ? const Color(0xFF10B981) : Colors.amber,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 22),
                    tooltip: "Close",
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Description
              Text(
                "Connect your free Google Gemini API key to empower the Anti-FOMO Devil's Advocate and purchase evaluator with unscripted, human-level psychological reasoning.",
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),

              // Model selector
              const Text(
                "SELECT MODEL",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: _buildModelOption(
                      title: "Gemini 2.5 Flash",
                      subtitle: "Fast & smart (Active)",
                      modelKey: "gemini-2.5-flash",
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildModelOption(
                      title: "Gemini Flash-Lite",
                      subtitle: "Fastest response time",
                      modelKey: "gemini-2.5-flash-lite",
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),

              // API Key Input
              const Text(
                "GEMINI API KEY",
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2030),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _testSucceeded == true
                        ? const Color(0xFF10B981).withValues(alpha: 0.6)
                        : _testSucceeded == false
                            ? Colors.redAccent.withValues(alpha: 0.6)
                            : Colors.white12,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: TextField(
                  controller: _keyController,
                  obscureText: _obscureText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontFamily: 'monospace',
                  ),
                  decoration: InputDecoration(
                    hintText: "AIzaSy...",
                    hintStyle: const TextStyle(color: Colors.white30, fontSize: 13),
                    border: InputBorder.none,
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _obscureText = !_obscureText;
                            });
                          },
                          icon: Icon(
                            _obscureText ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                            color: Colors.white54,
                            size: 18,
                          ),
                          tooltip: _obscureText ? "Show key" : "Hide key",
                        ),
                        if (_keyController.text.isNotEmpty)
                          IconButton(
                            onPressed: () {
                              _keyController.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.clear_rounded, color: Colors.white38, size: 18),
                            tooltip: "Clear input",
                          ),
                      ],
                    ),
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 10),

              // Free API Key Helper Link Info
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppTheme.primaryTeal, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        "Don't have a key? Grab a 100% free API key from Google AI Studio (${AiConfig.getApiKeyUrl}).",
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Feedback Banner
              if (_statusFeedback != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: _testSucceeded == true
                        ? const Color(0xFF10B981).withValues(alpha: 0.12)
                        : Colors.redAccent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _testSucceeded == true
                          ? const Color(0xFF10B981).withValues(alpha: 0.3)
                          : Colors.redAccent.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _testSucceeded == true
                            ? Icons.check_circle_outline_rounded
                            : Icons.error_outline_rounded,
                        color: _testSucceeded == true ? const Color(0xFF10B981) : Colors.redAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _statusFeedback!,
                          style: TextStyle(
                            color: _testSucceeded == true
                                ? const Color(0xFF10B981)
                                : Colors.redAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn().slideY(begin: 0.1, end: 0),
              ],
              const SizedBox(height: 24),

              // Buttons
              Row(
                children: [
                  if (hasActiveKey)
                    TextButton.icon(
                      onPressed: _isTesting ? null : _clearKey,
                      icon: const Icon(Icons.delete_outline_rounded, size: 16, color: Colors.white54),
                      label: const Text(
                        "Disconnect",
                        style: TextStyle(color: Colors.white54, fontSize: 13),
                      ),
                    ),
                  const Spacer(),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    child: const Text("Done"),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: _isTesting ? null : _testAndSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryTeal,
                      foregroundColor: Colors.black,
                      elevation: 0,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: _isTesting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.black,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.bolt_rounded, size: 18),
                              SizedBox(width: 6),
                              Text(
                                "Verify & Connect",
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                              ),
                            ],
                          ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModelOption({
    required String title,
    required String subtitle,
    required String modelKey,
  }) {
    final isSelected = _selectedModel == modelKey;
    return InkWell(
      onTap: () {
        setState(() {
          _selectedModel = modelKey;
        });
        GeminiService.instance.setModel(modelKey);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.fomoPurple.withValues(alpha: 0.15) : const Color(0xFF1B2030),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AppTheme.fomoPurple : Colors.white12,
            width: isSelected ? 1.5 : 1.0,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.white70,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(Icons.check_circle_rounded, color: AppTheme.fomoPurple, size: 14),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                color: isSelected ? AppTheme.fomoPurple.withValues(alpha: 0.8) : Colors.white38,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
