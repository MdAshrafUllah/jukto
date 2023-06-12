import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'authentication/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const loginpage(),
      theme: ThemeData(
        textTheme: GoogleFonts.robotoTextTheme(textTheme),
      ),
    );
  }
}
