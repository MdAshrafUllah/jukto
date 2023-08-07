import 'package:flutter/material.dart';

class AboutApp extends StatelessWidget {
  const AboutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About The App',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About JUKTO',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'This is a University-Based Social App JUKTO. Using the app, all students will be connected to one network. They can send Friend requests, Share posts, give likes and comments, and message their friends. They can store the payment History with the total calculation they give to the university. They can add their subject and the result of their previous semester. After adding, they can see their semester-wise GPA and their running CGPA. They can add Class and exam routines on different pages. They can set an alarm for class or meet any other requirements. They can create Group for chatting with friends And more.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 24.0),
            Text(
              'Dark Mode',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
            ),
            Text(
              'With this app, you can also use Dark Mode.',
              style: TextStyle(fontSize: 16.0),
            ),
            SizedBox(height: 24.0),
            Center(
              child: Text(
                'App Version: 1.0.0',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
