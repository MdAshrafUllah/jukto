import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

import 'authentication/loginPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
    return ChangeNotifierProvider(
      create: (context) => ThemeProvider(),
      builder: (context, _) {
        final textTheme = Theme.of(context).textTheme;
        final themeProvider = Provider.of<ThemeProvider>(context);
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          themeMode: themeProvider.themeMode,
          home: const loginpage(),
          theme: ThemeData(
            brightness: Brightness.light,
            textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
              bodyMedium: TextStyle(
                color: Colors.black, // Change text color based on theme mode
              ),
            ),
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            textTheme: GoogleFonts.robotoTextTheme(textTheme).copyWith(
              bodyMedium: TextStyle(
                color: Colors.white, // Change text color based on theme mode
              ),
            ),
          ),
        );
      },
    );
  }
}
