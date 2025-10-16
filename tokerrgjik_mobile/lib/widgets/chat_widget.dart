import 'package:flutter/material.dart';
import 'package:tokerrgjik_mobile/services/socket_service.dart';

class ChatWidget extends StatefulWidget {
  final SocketService socketService;
  const ChatWidget({super.key, required this.socketService});

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final _chatController = TextEditingController();
  final List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    // Listen for chat messages from the server
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) => Text(_messages[index]),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _chatController,
                  decoration: const InputDecoration(hintText: 'Send a message'),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: () {
                  if (_chatController.text.isNotEmpty) {
                    widget.socketService.sendChatMessage(_chatController.text);
                    _chatController.clear();
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
