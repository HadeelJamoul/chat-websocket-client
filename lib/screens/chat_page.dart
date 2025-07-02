import 'dart:convert';
import 'package:chat_websocket_client/model/chat_message_model.dart';
import 'package:chat_websocket_client/services/cloudinary_service.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';


class ChatPage extends StatefulWidget {
  final WebSocketChannel channel;

  const ChatPage({super.key, required this.channel});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _controller = TextEditingController();
  final List<ChatMessageModel> _messages = [];
  final userId = const Uuid().v4();

  @override
  void initState() {
    super.initState();

    //* Message listeners
    widget.channel.stream.listen((message) {
      final decoded = jsonDecode(message);
      final isMe = decoded['sender'] == userId;

      setState(() {
        _messages.add(
          ChatMessageModel(
            content: decoded['content'],
            isMe: isMe,
            type: decoded['type'],
          ),
        );
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final message = {
        'sender': userId,
        'type': 'text',
        'content': _controller.text,
      };

      widget.channel.sink.add(jsonEncode(message));

      _controller.clear();
    }
  }

  void _sendImage(String imageUrl) {
    final message = {'sender': userId, 'type': 'image', 'content': imageUrl};

    widget.channel.sink.add(jsonEncode(message));
  }

  @override
  void dispose() {
    widget.channel.sink.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('WebSocket Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              padding: const EdgeInsets.all(8),
              itemBuilder: (context, index) {
                final msg = _messages[index];
                return Align(
                  alignment:
                      msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: msg.isMe ? Colors.blue[100] : Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child:
                        msg.type == 'image'
                            ? Image.network(msg.content, width: 200)
                            : Text(msg.content),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () async {
              final url = await CloudinaryService.uploadImage();
              if (url != null) {
                _sendImage(url);
              }
            },
            child: const Text('Upload Image'),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
