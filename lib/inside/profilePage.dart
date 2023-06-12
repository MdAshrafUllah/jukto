import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../authentication/loginPage.dart';
import '../calculator/totalcgpa.dart';

class profilePage extends StatefulWidget {
  const profilePage({super.key});

  @override
  State<profilePage> createState() => _profilePageState();
}

class _profilePageState extends State<profilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 25,
            ),
            Container(
              height: 150,
              width: 150,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: NetworkImage(
                      'https://img.freepik.com/free-photo/young-bearded-man-with-striped-shirt_273609-5677.jpg?w=2000'),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                'Md Jakir Hossen',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'CSE Department',
                style: TextStyle(
                  fontFamily: 'Roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.w300,
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => totalCGPApage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 4,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Total CGPA: 3.33',
                  style: TextStyle(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 4,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Complete Credits: 129',
                  style: TextStyle(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 4,
                    color: Color.fromRGBO(58, 150, 255, 1),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Complete Subjects: 43',
                  style: TextStyle(
                    color: Color.fromRGBO(58, 150, 255, 1),
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(58, 150, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Total Payments',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(58, 150, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Class Routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (Context) => loginpage()));
              },
              child: Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                padding: EdgeInsets.only(left: 20, right: 20),
                height: 70,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(58, 150, 255, 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Exam Routine',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Roboto',
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 25,
            ),
          ],
        ),
      ),
    );
  }
}
