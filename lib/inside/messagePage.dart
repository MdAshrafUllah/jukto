import 'package:flutter/material.dart';
import 'package:jukto/group_chats/group_chat_screen.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

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
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        child: Icon(Icons.group,
            color: Provider.of<ThemeProvider>(context).isDarkMode
                ? Colors.black
                : Colors.white),
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => GroupChatHomeScreen(),
          ),
        ),
      ),
    );
  }
}
