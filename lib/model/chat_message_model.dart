// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:chat_websocket_client/utils/app_enums.dart';

class ChatMessageModel {
  final String content;
  final bool isMe;
  final MessageType type;

  ChatMessageModel({
    required this.content,
    required this.isMe,
    required this.type,
  });
}
