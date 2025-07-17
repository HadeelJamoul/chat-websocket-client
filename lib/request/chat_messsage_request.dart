class ChatMessageRequest {
  final String sender;
  final String type;
  final String content;

  ChatMessageRequest({
    required this.sender,
    required this.type,
    required this.content,
  });

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'type': type, 'content': content};
  }
}
