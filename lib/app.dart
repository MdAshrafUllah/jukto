import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

import 'authentication/loginPage.dart';

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);
  @override
  AppState createState() => AppState();
}

class AppState extends State<App> {
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
