import 'package:chat_websocket_client/core/url.dart';
import 'package:chat_websocket_client/screens/chat_page.dart';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

//? MVP Minimum Viable Product.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebSocket Chat Client',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ChatPage(
        channel: WebSocketChannel.connect(Uri.parse(Url.WS_SERVER)),
      ),
    );
  }
}
