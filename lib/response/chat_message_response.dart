class ChatMessageResponse {
  final String sender;
  final String type;
  final String content;

  ChatMessageResponse({
    required this.sender,
    required this.type,
    required this.content,
  });

  factory ChatMessageResponse.fromJson(Map<String, dynamic> json) {
    return ChatMessageResponse(
      sender: json['sender'],
      type: json['type'],
      content: json['content'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'type': type, 'content': content};
  }
}
