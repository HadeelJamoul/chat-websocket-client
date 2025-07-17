import 'dart:convert';

import 'package:chat_websocket_client/model/chat_message_model.dart';
import 'package:chat_websocket_client/request/chat_messsage_request.dart';
import 'package:chat_websocket_client/response/chat_message_response.dart';
import 'package:chat_websocket_client/services/cloudinary_service.dart';
import 'package:chat_websocket_client/utils/app_enums.dart';
import 'package:flutter/material.dart';
import 'package:logger/web.dart';
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
  final String userId = const Uuid().v4();
  final Logger logger = Logger();

  @override
  void initState() {
    super.initState();

    widget.channel.stream.listen((message) {
      final decoded = jsonDecode(message);
      final response = ChatMessageResponse.fromJson(decoded);
      final isMe = response.sender == userId;

      setState(() {
        _messages.add(
          ChatMessageModel(
            content: response.content,
            isMe: isMe,
            type: MessageType.fromString(response.type),
          ),
        );
      });
    });
  }

  void _sendMessage() {
    if (_controller.text.isNotEmpty) {
      final request = ChatMessageRequest(
        sender: userId,
        type: MessageType.getString(MessageType.TEXT),
        content: _controller.text,
      );

      final String encoded = jsonEncode(request.toJson());
      logger.i('Sending text message: $encoded');
      widget.channel.sink.add(encoded);

      _controller.clear();
    }
  }

  void _sendImage(String imageUrl) {
    final request = ChatMessageRequest(
      sender: userId,
      type: MessageType.getString(MessageType.IMAGE),
      content: imageUrl,
    );

    final String encoded = jsonEncode(request.toJson());
    logger.i('Sending image message: $encoded');
    widget.channel.sink.add(encoded);
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
                        msg.type == MessageType.IMAGE
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
