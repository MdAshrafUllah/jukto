import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest_10y.dart' as tz;
import 'package:flutter_downloader/flutter_downloader.dart';

import 'package:jukto/theme/theme.dart';

import 'authentication/loginPage.dart';

FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize();
  await Firebase.initializeApp();
  tz.initializeTimeZones();
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  AndroidInitializationSettings androidSetting =
      AndroidInitializationSettings("@mipmap/ic_launcher");

  InitializationSettings initializationSettings = InitializationSettings(
    android: androidSetting,
  );

  notificationsPlugin.initialize(initializationSettings);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final themeProvider = ThemeProvider();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          final textTheme = Theme.of(context).textTheme;
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            themeMode: themeProvider.themeMode,
            home: const LoginPage(),
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
      ),
    );
  }
}
