import 'package:flutter/material.dart';
import 'package:jukto/group_chats/group_chat_screen.dart';

class messagePage extends StatefulWidget {
  const messagePage({super.key});

  @override
  State<messagePage> createState() => _messagePageState();
}

class _messagePageState extends State<messagePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.group),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}
