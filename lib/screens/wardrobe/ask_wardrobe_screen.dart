import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/wardrobe_service.dart';
import '../../services/ai_service.dart';
import '../../services/auth_service.dart';

class _ChatMessage {
  final bool isUser;
  final String text;
  _ChatMessage({required this.isUser, required this.text});

  Map<String, dynamic> toJson() => {'isUser': isUser, 'text': text};
  factory _ChatMessage.fromJson(Map<String, dynamic> json) =>
      _ChatMessage(isUser: json['isUser'] as bool, text: json['text'] as String);
}

class AskWardrobeScreen extends StatefulWidget {
  const AskWardrobeScreen({super.key});

  @override
  State<AskWardrobeScreen> createState() => _AskWardrobeScreenState();
}

class _AskWardrobeScreenState extends State<AskWardrobeScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  bool _loading = true;
  String? _userEmail;

  static const _suggestedQuestions = [
    'What should I wear today?',
    'Do I have a black jacket?',
    'Match my blue jeans',
  ];

  @override
  void initState() {
    super.initState();
    _userEmail = context.read<AuthService>().currentUser?.email;
    _loadHistory();
  }

  String get _historyKey => 'stylemate_chat_v1_${_userEmail ?? "guest"}';

  Future<void> _loadHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_historyKey);
    if (saved != null) {
      final List<dynamic> list = jsonDecode(saved);
      _messages.addAll(list.map((e) => _ChatMessage.fromJson(e as Map<String, dynamic>)));
    } else {
      final wardrobe = context.read<WardrobeService>();
      _messages.add(_ChatMessage(
        isUser: false,
        text: "Hi! I'm your StyleMate assistant. I've looked at your wardrobe of ${wardrobe.items.length} items. What do you want to know?",
      ));
    }
    if (!mounted) return;
    setState(() => _loading = false);
    _scrollToBottom();
  }

  Future<void> _persistHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_historyKey, jsonEncode(_messages.map((m) => m.toJson()).toList()));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _controller.text).trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(isUser: true, text: text));
      _loading = true;
      _controller.clear();
    });
    _persistHistory();
    _scrollToBottom();

    final wardrobe = context.read<WardrobeService>();
    final ai = context.read<AiService>();
    final answer = await ai.askWardrobe(wardrobe: wardrobe.items, query: text);
    if (!mounted) return;
    setState(() {
      _messages.add(_ChatMessage(isUser: false, text: answer));
      _loading = false;
    });
    _persistHistory();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ask StyleMate'),
        actions: [
          IconButton(
            tooltip: 'Clear chat',
            icon: const Icon(Icons.delete_outline),
            onPressed: _messages.length <= 1
                ? null
                : () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Clear conversation?'),
                        content: const Text('This removes your chat history with StyleMate.'),
                        actions: [
                          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Clear')),
                        ],
                      ),
                    );
                    if (confirmed != true) return;
                    setState(() => _messages.clear());
                    await _loadHistory0(); // re-seed the greeting
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _loading && _messages.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_loading && _messages.isNotEmpty ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length) {
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
                            child: const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                          ),
                        );
                      }
                      final msg = _messages[i];
                      return Align(
                        alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: msg.isUser ? theme.colorScheme.primary : Colors.white,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Text(
                            msg.text,
                            style: TextStyle(color: msg.isUser ? Colors.white : theme.textTheme.bodyMedium?.color),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (_messages.length <= 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _suggestedQuestions
                    .map((q) => ActionChip(label: Text(q, style: const TextStyle(fontSize: 12)), onPressed: () => _send(q)))
                    .toList(),
              ),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Ask your wardrobe...',
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _send(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary,
                    child: IconButton(icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 18), onPressed: () => _send()),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadHistory0() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_historyKey);
    final wardrobe = context.read<WardrobeService>();
    setState(() {
      _messages.add(_ChatMessage(
        isUser: false,
        text: "Hi! I'm your StyleMate assistant. I've looked at your wardrobe of ${wardrobe.items.length} items. What do you want to know?",
      ));
    });
    _persistHistory();
  }
}
