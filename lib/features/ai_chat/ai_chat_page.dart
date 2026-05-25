import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AiChatPage extends StatefulWidget {
  const AiChatPage({super.key});

  @override
  State<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends State<AiChatPage> {
  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  bool _isTyping = false;

  List<_ChatSession> _sessions = [];

  late _ChatSession _currentSession;

  @override
  void initState() {
    super.initState();
    _loadSessions();
  }

  @override
  void dispose() {
    _inputCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadSessions() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getStringList('ai_chat_sessions');

    if (data != null && data.isNotEmpty) {
      _sessions =
          data
              .map(
                (e) => _ChatSession.fromJson(
              jsonDecode(e),
            ),
          )
              .toList();

      _currentSession = _sessions.first;
    } else {
      _createNewSession(initial: true);
    }

    setState(() {});
  }

  Future<void> _saveSessions() async {
    final prefs = await SharedPreferences.getInstance();

    final data =
    _sessions.map((e) => jsonEncode(e.toJson())).toList();

    await prefs.setStringList('ai_chat_sessions', data);
  }

  void _createNewSession({bool initial = false}) {
    final session = _ChatSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: 'New Session',
      messages: [
        _ChatMessage(
          isAi: true,
          text:
          "Hello mayur! I'm your take.health Coach.\n\nI can help you analyze medical reports, plan your nutrition, or answer any health-related questions. What's on your mind?",
          showCopy: true,
        ),
      ],
    );

    _sessions.insert(0, session);

    _currentSession = session;

    _saveSessions();

    if (!initial) {
      Navigator.pop(context);
    }

    setState(() {});
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;

    setState(() {
      _currentSession.messages.add(
        _ChatMessage(
          isAi: false,
          text: text.trim(),
        ),
      );

      _isTyping = true;
    });

    _inputCtrl.clear();

    _saveSessions();

    _scrollToBottom();

    Future.delayed(const Duration(milliseconds: 1200), () {
      setState(() {
        _isTyping = false;

        _currentSession.messages.add(
          _ChatMessage(
            isAi: true,
            text: _generateResponse(text.trim()),
            showCopy: true,
            bullets: _generateBullets(text.trim()),
          ),
        );
      });

      _saveSessions();

      _scrollToBottom();
    });
  }

  String _generateResponse(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('dinner')) {
      return "Great question! Based on your nutrition goals, here are some healthy dinner ideas for you:";
    }

    if (lower.contains('gain') || lower.contains('weight')) {
      return "Hey Mayur! I appreciate you sharing your goal, but I want to be straightforward with you here.\n\nCurrent Situation:";
    }

    return "Thanks for reaching out! Based on your health profile, here's what I recommend:";
  }

  List<String>? _generateBullets(String input) {
    final lower = input.toLowerCase();

    if (lower.contains('dinner')) {
      return [
        "Grilled chicken with steamed vegetables and brown rice",
        "Dal with roti and a side salad — high protein, balanced carbs",
        "Paneer tikka with quinoa — great for muscle support",
      ];
    }

    if (lower.contains('gain') || lower.contains('weight')) {
      return [
        "Your current weight appears to be around 54 kg",
        "Your fitness goal is set to 64 kg",
      ];
    }

    return null;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 350),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _showHistorySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.92,
          decoration: const BoxDecoration(
            color: Color(0xFFF5F5F7),
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(30),
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                     width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.history,
                        color: Colors.white,
                        size: 17,
                      ),
                    ),

                    const SizedBox(width: 16),

                    const Text(
                      'HISTORY',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),

                    const Spacer(),

                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 32,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: GestureDetector(
                  onTap: _createNewSession,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: Text(
                        '+ NEW SESSION',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 40),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blueGrey.shade200,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              Expanded(
                child:
                _sessions.isEmpty
                    ? Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                    ),
                    padding: const EdgeInsets.symmetric(
                      vertical: 34,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                    ),
                    child: const Center(
                      child: Text(
                        'No recent health queries.',
                        style: TextStyle(
                          fontSize: 18,
                          fontStyle: FontStyle.italic,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  itemCount: _sessions.length,
                  itemBuilder: (_, index) {
                    final session = _sessions[index];

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _currentSession = session;
                        });

                        Navigator.pop(context);
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(22),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFE8F5EE,
                                ),
                                borderRadius:
                                BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.chat_bubble_outline,
                                color: Color(0xFF4A9B6E),
                              ),
                            ),

                            const SizedBox(width: 14),

                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    session.messages.length > 1
                                        ? session.messages[1].text
                                        : "New Session",
                                    maxLines: 1,
                                    overflow:
                                    TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight:
                                      FontWeight.w700,
                                      fontSize: 15,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    '${session.messages.length} messages',
                                    style: TextStyle(
                                      color:
                                      Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(
                  bottom: 28,
                  top: 12,
                ),
                child: GestureDetector(
                  onTap: () async {
                    final prefs =
                    await SharedPreferences.getInstance();

                    await prefs.remove('ai_chat_sessions');

                    setState(() {
                      _sessions.clear();
                    });

                    Navigator.pop(context);

                    _createNewSession();
                  },
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Color(0xFFE74867),
                      ),

                      SizedBox(width: 10),

                      Text(
                        'CLEAR ALL DATA',
                        style: TextStyle(
                          color: Color(0xFFE74867),
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2,
                          fontSize: 13
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sessions.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AI Health Coach',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _showHistorySheet,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.history_rounded,
                      size: 20,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              controller: _scrollCtrl,
              padding: const EdgeInsets.fromLTRB(
                16,
                12,
                16,
                12,
              ),
              itemCount:
              _currentSession.messages.length +
                  (_isTyping ? 1 : 0),
              itemBuilder: (context, index) {
                if (_isTyping &&
                    index == _currentSession.messages.length) {
                  return const _TypingIndicator();
                }

                final msg = _currentSession.messages[index];

                return msg.isAi
                    ? _AiMessageBubble(message: msg)
                    : _UserMessageBubble(message: msg);
              },
            ),
          ),

          _ChatInputBar(
            controller: _inputCtrl,
            onSend: () => _sendMessage(_inputCtrl.text),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isAi;
  final String text;
  final bool showCopy;
  final List<String>? bullets;

  const _ChatMessage({
    required this.isAi,
    required this.text,
    this.showCopy = false,
    this.bullets,
  });

  Map<String, dynamic> toJson() {
    return {
      'isAi': isAi,
      'text': text,
      'showCopy': showCopy,
      'bullets': bullets,
    };
  }

  factory _ChatMessage.fromJson(Map<String, dynamic> json) {
    return _ChatMessage(
      isAi: json['isAi'],
      text: json['text'],
      showCopy: json['showCopy'] ?? false,
      bullets:
      json['bullets'] != null
          ? List<String>.from(json['bullets'])
          : null,
    );
  }
}

class _ChatSession {
  final String id;
  final String title;
  final List<_ChatMessage> messages;

  _ChatSession({
    required this.id,
    required this.title,
    required this.messages,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'messages': messages.map((e) => e.toJson()).toList(),
    };
  }

  factory _ChatSession.fromJson(Map<String, dynamic> json) {
    return _ChatSession(
      id: json['id'],
      title: json['title'],
      messages:
      (json['messages'] as List)
          .map((e) => _ChatMessage.fromJson(e))
          .toList(),
    );
  }
}

class _AiMessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _AiMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5EE),
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF4A9B6E),
                width: 1.5,
              ),
            ),
            child: const Icon(
              Icons.health_and_safety,
              color: Color(0xFF4A9B6E),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  message.text,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF1A1A1A),
                    height: 1.5,
                  ),
                ),

                if (message.bullets != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Column(
                      children:
                      message.bullets!
                          .map(
                            (e) => Padding(
                          padding:
                          const EdgeInsets.only(
                            bottom: 10,
                          ),
                          child: Row(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: [
                              const Text("• "),

                              Expanded(
                                child: Text(
                                  e,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                          .toList(),
                    ),
                  ),

                if (message.showCopy)
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(
                          ClipboardData(text: message.text),
                        );
                      },
                      child: Icon(
                        Icons.copy_rounded,
                        size: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _UserMessageBubble extends StatelessWidget {
  final _ChatMessage message;

  const _UserMessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          constraints: BoxConstraints(
            maxWidth:
            MediaQuery.of(context).size.width * 0.75,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 14,
          ),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Text(
            message.text,
            style: const TextStyle(
              fontSize: 15,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatefulWidget {
  const _TypingIndicator();

  @override
  State<_TypingIndicator> createState() =>
      _TypingIndicatorState();
}

class _TypingIndicatorState extends State<_TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.more_horiz),

        const SizedBox(width: 10),

        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) {
            return const Text("AI is typing...");
          },
        ),
      ],
    );
  }
}

class _ChatInputBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;

  const _ChatInputBar({
    required this.controller,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(
        12,
        10,
        12,
        24,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: 'Ask something...',
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const SizedBox(width: 10),

          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: Color(0xFF4A9B6E),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.send_rounded,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}