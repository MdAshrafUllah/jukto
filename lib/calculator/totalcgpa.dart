import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalCGPApage extends StatefulWidget {
  const TotalCGPApage({
    Key? key,
  }) : super(key: key);
  @override
  TotalCGPApageState createState() => TotalCGPApageState();
}

class TotalCGPApageState extends State<TotalCGPApage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;

  String UserID = '';
  final semesterOneCreditController = TextEditingController();
  final semesterOnePointController = TextEditingController();
  final semesterTwoCreditController = TextEditingController();
  final semesterTwoPointController = TextEditingController();
  final semesterThreeCreditController = TextEditingController();
  final semesterThreePointController = TextEditingController();
  final semesterFourCreditController = TextEditingController();
  final semesterFourPointController = TextEditingController();
  final semesterFiveCreditController = TextEditingController();
  final semesterFivePointController = TextEditingController();
  final semesterSixCreditController = TextEditingController();
  final semesterSixPointController = TextEditingController();
  final semesterSevenCreditController = TextEditingController();
  final semesterSevenPointController = TextEditingController();
  final semesterEightCreditController = TextEditingController();
  final semesterEightPointController = TextEditingController();
  final totalCreditController = TextEditingController();
  final totalPointController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (auth.currentUser != null) {
      user = auth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          String documentId = doc.id;
          print('Document ID: $documentId');
          print('Document Data: ${doc.data()}');
          UserID = documentId;

          Map<String, dynamic>? data = doc.data() as Map<String, dynamic>?;
          List<dynamic>? cgpaData = data?['cgpa'] as List<dynamic>?;

          cgpaData?.forEach((semesterData) {
            String semester = semesterData?['semester'] as String? ?? '';
            String credit =
                semesterData?['credit']?.toString() as String? ?? '';
            String point = semesterData?['point']?.toString() as String? ?? '';

            switch (semester) {
              case 'semester 1':
                semesterOneCreditController.text = credit;
                semesterOnePointController.text = point;
                break;
              case 'semester 2':
                semesterTwoCreditController.text = credit;
                semesterTwoPointController.text = point;
                break;
              case 'semester 3':
                semesterThreeCreditController.text = credit;
                semesterThreePointController.text = point;
                break;
              case 'semester 4':
                semesterFourCreditController.text = credit;
                semesterFourPointController.text = point;
                break;
              case 'semester 5':
                semesterFiveCreditController.text = credit;
                semesterFivePointController.text = point;
                break;
              case 'semester 6':
                semesterSixCreditController.text = credit;
                semesterSixPointController.text = point;
                break;
              case 'semester 7':
                semesterSevenCreditController.text = credit;
                semesterSevenPointController.text = point;
                break;
              case 'semester 8':
                semesterEightCreditController.text = credit;
                semesterEightPointController.text = point;
                break;
            }
          });

          calculateTotalCredit();
          calculateTotalCGPA();
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total CGPA',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 1',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterOneCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterOnePointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 2',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterTwoCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterTwoPointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 3',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterThreeCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterThreePointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 4',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterFourCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterFourPointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 5',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterFiveCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterFivePointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 6',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterSixCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterSixPointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 7',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterSevenCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterSevenPointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'semester 8',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        controller: semesterEightCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCredit();
                        },
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      width: 150,
                      child: TextField(
                        controller: semesterEightPointController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (value) {
                          calculateTotalCGPA();
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Container(
              margin: EdgeInsets.only(left: 10, top: 20, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Text(
                      'Total',
                      style: TextStyle(
                        fontFamily: 'Roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        enabled: false,
                        controller: totalCreditController,
                        style: TextStyle(fontSize: 12),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Credit',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: SizedBox(
                      width: 150,
                      child: TextField(
                        enabled: false,
                        controller: totalPointController,
                        style: const TextStyle(fontSize: 12),
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Point',
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            MaterialButton(
              onPressed: () {
                saveData();
              },
              shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(5))),
              color: Colors.green,
              height: 50,
              minWidth: 142,
              child: const Text(
                "Save",
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  double calculateTotalCredit() {
    double totalCredit = 0;
    totalCredit += double.tryParse(semesterOneCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterTwoCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterThreeCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterFourCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterFiveCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterSixCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterSevenCreditController.text) ?? 0;
    totalCredit += double.tryParse(semesterEightCreditController.text) ?? 0;

    totalCreditController.text = totalCredit.toStringAsFixed(2);
    return totalCredit;
  }

  double calculateTotalCGPA() {
    double? semesterOneCredit =
        double.tryParse(semesterOneCreditController.text);
    double? semesterOnePoint = double.tryParse(semesterOnePointController.text);
    double? semesterTwoCredit =
        double.tryParse(semesterTwoCreditController.text);
    double? semesterTwoPoint = double.tryParse(semesterTwoPointController.text);
    double? semesterThreeCredit =
        double.tryParse(semesterThreeCreditController.text);
    double? semesterThreePoint =
        double.tryParse(semesterThreePointController.text);
    double? semesterFourCredit =
        double.tryParse(semesterFourCreditController.text);
    double? semesterFourPoint =
        double.tryParse(semesterFourPointController.text);
    double? semesterFiveCredit =
        double.tryParse(semesterFiveCreditController.text);
    double? semesterFivePoint =
        double.tryParse(semesterFivePointController.text);
    double? semesterSixCredit =
        double.tryParse(semesterSixCreditController.text);
    double? semesterSixPoint = double.tryParse(semesterSixPointController.text);
    double? semesterSevenCredit =
        double.tryParse(semesterSevenCreditController.text);
    double? semesterSevenPoint =
        double.tryParse(semesterSevenPointController.text);
    double? semesterEightCredit =
        double.tryParse(semesterEightCreditController.text);
    double? semesterEightPoint =
        double.tryParse(semesterEightPointController.text);

    semesterOneCredit ??= 0;
    semesterOnePoint ??= 0;
    semesterTwoCredit ??= 0;
    semesterTwoPoint ??= 0;
    semesterThreeCredit ??= 0;
    semesterThreePoint ??= 0;
    semesterFourCredit ??= 0;
    semesterFourPoint ??= 0;
    semesterFiveCredit ??= 0;
    semesterFivePoint ??= 0;
    semesterSixCredit ??= 0;
    semesterSixPoint ??= 0;
    semesterSevenCredit ??= 0;
    semesterSevenPoint ??= 0;
    semesterEightCredit ??= 0;
    semesterEightPoint ??= 0;

    double totalCredit = calculateTotalCredit();
    double totalCGPATop = (semesterOneCredit * semesterOnePoint) +
        (semesterTwoCredit * semesterTwoPoint) +
        (semesterThreeCredit * semesterThreePoint) +
        (semesterFourCredit * semesterFourPoint) +
        (semesterFiveCredit * semesterFivePoint) +
        (semesterSixCredit * semesterSixPoint) +
        (semesterSevenCredit * semesterSevenPoint) +
        (semesterEightCredit * semesterEightPoint);

    double totalCGPA = totalCGPATop / totalCredit;

    totalPointController.text = totalCGPA.toStringAsFixed(2);
    return totalCGPA;
  }

  void saveData() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(UserID)
        .update({
          'cgpa': [
            {
              'semester': 'semester 1',
              'credit': semesterOneCreditController.text,
              'point': semesterOnePointController.text,
            },
            {
              'semester': 'semester 2',
              'credit': semesterTwoCreditController.text,
              'point': semesterTwoPointController.text,
            },
            {
              'semester': 'semester 3',
              'credit': semesterThreeCreditController.text,
              'point': semesterThreePointController.text,
            },
            {
              'semester': 'semester 4',
              'credit': semesterFourCreditController.text,
              'point': semesterFourPointController.text,
            },
            {
              'semester': 'semester 5',
              'credit': semesterFiveCreditController.text,
              'point': semesterFivePointController.text,
            },
            {
              'semester': 'semester 6',
              'credit': semesterSixCreditController.text,
              'point': semesterSixPointController.text,
            },
            {
              'semester': 'semester 7',
              'credit': semesterSevenCreditController.text,
              'point': semesterSevenPointController.text,
            },
            {
              'semester': 'semester 8',
              'credit': semesterEightCreditController.text,
              'point': semesterEightPointController.text,
            },
          ],
        })
        .then((value) => print('Data saved successfully.'))
        .catchError((error) => print('Failed to save data: $error'));
  }
}
