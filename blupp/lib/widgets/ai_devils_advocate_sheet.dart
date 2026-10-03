import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/finance_state.dart';
import '../services/ai_devils_advocate_engine.dart';
import '../theme/app_theme.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final Map<String, dynamic>? aiCardData;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.aiCardData,
  });
}

class AiDevilsAdvocateSheet extends StatefulWidget {
  final FinanceState state;
  final String? initialItem;
  final double? initialPrice;

  const AiDevilsAdvocateSheet({
    super.key,
    required this.state,
    this.initialItem,
    this.initialPrice,
  });

  @override
  State<AiDevilsAdvocateSheet> createState() => _AiDevilsAdvocateSheetState();
}

class _AiDevilsAdvocateSheetState extends State<AiDevilsAdvocateSheet> {
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  String? _activeItem;
  double? _activePrice;
  List<String> _dynamicChips = [
    "Sony WH-1000XM5 RM 1,499",
    "Shopee keyboard RM 350",
    "Concert ticket RM 480",
    "Sneakers RM 280",
  ];

  @override
  void initState() {
    super.initState();
    _activeItem = widget.initialItem;
    _activePrice = widget.initialPrice;
    _initChat();
  }

  void _initChat() {
    final name = widget.state.userName;
    final spendingLeft = widget.state.spendingBalanceLeft;
    final debt = widget.state.totalLoans;

    String initialGreeting = "Hey $name! I'm your AI Devil's Advocate. My job is to protect your future wealth from today's impulsive dopamine cravings.\n\n"
        "You currently have ${AppTheme.formatCurrency(spendingLeft)} spending allowance left this month";

    if (debt > 0) {
      initialGreeting += " and ${AppTheme.formatCurrency(debt)} in liabilities to clear.";
    } else {
      initialGreeting += " with zero debt obligations. Let's keep it that way!";
    }

    initialGreeting += "\n\nWhat impulse purchase are you tempted by today?";

    _messages.add(ChatMessage(
      text: initialGreeting,
      isUser: false,
      timestamp: DateTime.now(),
    ));

    if (widget.initialItem != null && (widget.initialPrice ?? 0) > 0) {
      final item = widget.initialItem!;
      final price = widget.initialPrice!;
      _inputController.text = "I really want to buy $item for RM ${price.toStringAsFixed(0)}";
      Future.delayed(const Duration(milliseconds: 300), () {
        _handleSendMessage();
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    });
  }

  void _handleSendMessage({String? overrideText}) async {
    final text = (overrideText ?? _inputController.text).trim();
    if (text.isEmpty || _isTyping) return;

    if (overrideText == null) {
      _inputController.clear();
    }

    // If user clicked direct cooldown action chip
    if (text.contains('🛡️ Lock into 30-Day Cooldown') || text.contains('Fine, put it on 30-day cooldown')) {
      _addCooldownItem(_activePrice ?? 150.0);
      return;
    }

    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });
    _scrollToBottom();

    // Context history for conversational coherence
    final history = _messages.map((m) => {
      'text': m.text,
      'isUser': m.isUser,
    }).toList();

    // Simulate intelligent neural reasoning delay
    await Future.delayed(const Duration(milliseconds: 750));

    final aiResponse = AiDevilsAdvocateEngine.generateResponse(
      userMessage: text,
      state: widget.state,
      currentItem: _activeItem,
      currentPrice: _activePrice,
      conversationHistory: history,
    );

    _activeItem = aiResponse.currentItem;
    _activePrice = aiResponse.currentPrice;

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _dynamicChips = aiResponse.suggestedChips;
      _messages.add(ChatMessage(
        text: aiResponse.text,
        isUser: false,
        timestamp: DateTime.now(),
        aiCardData: aiResponse.cardData,
      ));
    });
    _scrollToBottom();
  }

  void _addCooldownItem(double price) {
    final itemName = (_activeItem != null && _activeItem!.isNotEmpty && _activeItem != 'this item')
        ? _activeItem!
        : "Resisted FOMO Item";
    widget.state.addToWishlist(
      itemName,
      price,
      'shopping',
      "FOMO Intercepted: 30-Day Cooling Chamber",
      "Saved ${AppTheme.formatCurrency(price)} from impulse spend. Added to 30-day cooldown.",
    );
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Text("🛡️ Added to 30-Day Cooldown Wishlist! You saved ${AppTheme.formatCurrency(price)}."),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.88,
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppTheme.surfaceBorder),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Color(0xFF8B5CF6), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              "AI Devil's Advocate",
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              "ANTI-FOMO AI",
                              style: TextStyle(color: Color(0xFFA78BFA), fontSize: 9, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        "Talk me out of impulse buying",
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: AppTheme.textMuted),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),

          // Chat Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _isTyping) {
                  return _buildTypingIndicator();
                }
                final msg = _messages[index];
                return _buildMessageBubble(msg);
              },
            ),
          ),

          // Quick Inspiration / Counter-Argument Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Row(
              children: _dynamicChips.map((chipText) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: _buildPromptChip(chipText),
                );
              }).toList(),
            ),
          ),

          // Input Bar
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 10 + MediaQuery.paddingOf(context).bottom),
            decoration: BoxDecoration(
              color: AppTheme.background,
              border: Border(top: BorderSide(color: AppTheme.surfaceBorder)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppTheme.surfaceBorder),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: TextField(
                      controller: _inputController,
                      style: TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "What do you want to buy? (e.g. iPad RM 1800)",
                        hintStyle: TextStyle(color: AppTheme.textMuted, fontSize: 13),
                        border: InputBorder.none,
                      ),
                      onSubmitted: (_) => _handleSendMessage(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  decoration: const BoxDecoration(
                    color: Color(0xFF8B5CF6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white, size: 20),
                    onPressed: _handleSendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChip(String text) {
    final isAction = text.startsWith('🛡️');
    return InkWell(
      onTap: () {
        _handleSendMessage(overrideText: text);
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: isAction
              ? const Color(0xFF10B981).withValues(alpha: 0.18)
              : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isAction
                ? const Color(0xFF10B981).withValues(alpha: 0.5)
                : AppTheme.surfaceBorder,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isAction) ...[
              const Icon(Icons.shield_rounded, size: 14, color: Color(0xFF10B981)),
              const SizedBox(width: 5),
            ],
            Text(
              text,
              style: TextStyle(
                color: isAction ? const Color(0xFF10B981) : AppTheme.textPrimary,
                fontSize: 12,
                fontWeight: isAction ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded, size: 16, color: Color(0xFFA78BFA)),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: isUser ? const Color(0xFF355FE5) : AppTheme.surfaceLight,
                    borderRadius: BorderRadius.circular(18).copyWith(
                      bottomRight: isUser ? const Radius.circular(4) : const Radius.circular(18),
                      bottomLeft: !isUser ? const Radius.circular(4) : const Radius.circular(18),
                    ),
                    border: Border.all(
                      color: isUser ? Colors.transparent : AppTheme.surfaceBorder,
                    ),
                  ),
                  child: Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : AppTheme.textPrimary,
                      fontSize: 13.5,
                      height: 1.45,
                    ),
                  ),
                ),

                // AI Opportunity Cost Breakdown Card
                if (msg.aiCardData != null) ...[
                  const SizedBox(height: 8),
                  _buildAiPsychometricsCard(msg.aiCardData!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiPsychometricsCard(Map<String, dynamic> data) {
    final price = data['price'] as double;
    final workHours = data['workHours'] as String;
    final futureValue = data['futureValue'] as double;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8B5CF6).withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bolt_rounded, size: 15, color: Color(0xFFA78BFA)),
              const SizedBox(width: 6),
              const Text(
                "AI Reality Check Telemetry",
                style: TextStyle(color: Color(0xFFA78BFA), fontSize: 11, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile("Work Cost", "$workHours hrs", Icons.work_history_rounded),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildMetricTile("10-Yr Compounding", AppTheme.formatCurrency(futureValue), Icons.trending_up_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.shield_rounded, size: 16),
              label: Text("Start 30-Day Cooldown (Save ${AppTheme.formatCurrency(price)})"),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF10B981),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              onPressed: () => _addCooldownItem(price),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 12, color: AppTheme.textMuted),
              const SizedBox(width: 4),
              Text(label, style: TextStyle(color: AppTheme.textMuted, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            value,
            style: TextStyle(color: AppTheme.textPrimary, fontSize: 12, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }



  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.surfaceBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(duration: 400.ms),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                ).animate(delay: 150.ms, onPlay: (c) => c.repeat(reverse: true)).scale(duration: 400.ms),
                const SizedBox(width: 4),
                Container(
                  width: 6,
                  height: 6,
                  decoration: const BoxDecoration(color: Color(0xFF8B5CF6), shape: BoxShape.circle),
                ).animate(delay: 300.ms, onPlay: (c) => c.repeat(reverse: true)).scale(duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
