import 'package:flutter/material.dart';

import '../services/ai_router.dart';

class AssistantScreen extends StatefulWidget {
  const AssistantScreen({super.key});

  @override
  State<AssistantScreen> createState() => _AssistantScreenState();
}

class _AssistantScreenState extends State<AssistantScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });

    try {
      final router = AiRouter.instance;
      final res = await router.handleUserMessage(text);
      setState(() {
        _messages.add(
          _ChatMessage(text: res.answer, isUser: false, sqlUsed: res.sqlUsed),
        );
      });
    } catch (e) {
      setState(() {
        _messages.add(
          _ChatMessage(
            text: 'Something went wrong while talking to the assistant: $e',
            isUser: false,
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _pasteQuestion(String question) {
    _controller.text = question;
  }

  Widget _buildQuestionButton(String question) {
    return OutlinedButton.icon(
      onPressed: () => _pasteQuestion(question),
      icon: const Icon(Icons.help_outline, size: 16),
      label: Text(
        question,
        style: const TextStyle(fontSize: 12),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: Theme.of(context).primaryColor),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('AgriBase AI Assistant'),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ask questions like:',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _buildQuestionButton(
                      'Which crop did best in 2024?',
                    ),
                    _buildQuestionButton(
                      'How to irrigate Aman rice in dry season?',
                    ),
                    _buildQuestionButton(
                      'Show yield statistics for Boro in 2023.',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg.isUser;
                final alignment = isUser
                    ? Alignment.centerRight
                    : Alignment.centerLeft;
                final bubbleColor = isUser
                    ? const Color.fromARGB(255, 0, 77, 64)
                    : theme.cardColor;
                final textColor = isUser
                    ? Colors.white
                    : theme.textTheme.bodyMedium?.color;

                return Align(
                  alignment: alignment,
                  child: Container(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: bubbleColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: isUser
                          ? CrossAxisAlignment.end
                          : CrossAxisAlignment.start,
                      children: [
                        Text(msg.text, style: TextStyle(color: textColor)),
                        if (msg.sqlUsed != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'SQL used:\n${msg.sqlUsed}',
                              style: TextStyle(
                                color: textColor?.withValues(alpha: 0.7),
                                fontSize: 11,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8),
              child: CircularProgressIndicator(),
            ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Ask AgriBase AI...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.send),
                    color: Theme.of(context).primaryColor,
                    onPressed: _isLoading ? null : _send,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChatMessage {
  _ChatMessage({required this.text, required this.isUser, this.sqlUsed});

  final String text;
  final bool isUser;
  final String? sqlUsed;
}
