import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CGPAPage extends StatefulWidget {
  const CGPAPage({Key? key}) : super(key: key);

  @override
  _CGPAPageState createState() => _CGPAPageState();
}

class _CGPAPageState extends State<CGPAPage> {
  Map<String, List<Map<String, dynamic>>> semesterData = {};

  FirebaseAuth auth = FirebaseAuth.instance;
  User? user;
  String userID = '';

  @override
  void initState() {
    super.initState();
    loadData();
    if (auth.currentUser != null) {
      user = auth.currentUser;
      FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user?.email)
          .get()
          .then((QuerySnapshot querySnapshot) {
        querySnapshot.docs.forEach((doc) {
          String documentId = doc.id;
          userID = documentId;
        });
      });
    }
  }

  Future<void> loadData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? semesterDataJson = prefs.getString('semesterData');
      if (semesterDataJson != null) {
        setState(() {
          semesterData = convertDataFormat(json.decode(semesterDataJson));
        });
      } else {
        FirebaseAuth auth = FirebaseAuth.instance;
        User? user = auth.currentUser;
        if (user != null) {
          FirebaseFirestore.instance
              .collection('users')
              .where('email', isEqualTo: user.email)
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              Map<String, dynamic>? userData =
                  doc.data() as Map<String, dynamic>?;
              setState(() {
                semesterData = convertDataFormat(userData!['CGPA'] ?? {});
              });
            });
          });
        }
      }
    } catch (error) {
      print('Failed to load data: $error');
    }
  }

  Map<String, List<Map<String, dynamic>>> convertDataFormat(
      Map<String, dynamic> data) {
    Map<String, List<Map<String, dynamic>>> convertedData = {};

    data.forEach((semesterName, subjects) {
      if (subjects is List) {
        convertedData[semesterName] = List<Map<String, dynamic>>.from(subjects);
      }
    });

    return convertedData;
  }

  double calculateSemesterGPA(List<Map<String, dynamic>> subjects) {
    double totalCreditGpa = 0.0;
    int totalCredit = 0;

    for (var subject in subjects) {
      int credit = subject['credit'];
      double gpa = subject['gpa'];

      totalCreditGpa += (credit * gpa);
      totalCredit += credit;
    }

    if (totalCredit == 0) {
      return 0.0;
    }

    return totalCreditGpa / totalCredit;
  }

  double calculateTotalCGPA() {
    double totalCreditGpa = 0.0;
    int totalCredit = 0;

    semesterData.forEach((semesterName, subjects) {
      int semesterCredit = 0;
      double semesterGpa = 0.0;

      subjects?.forEach((subject) {
        int credit = subject['credit'];
        double gpa = subject['gpa'];

        semesterCredit += credit;
        semesterGpa += (credit * gpa);
      });

      totalCreditGpa += semesterGpa;
      totalCredit += semesterCredit;
    });

    if (totalCredit == 0) {
      return 0.0;
    }

    return totalCreditGpa / totalCredit;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    bool isSemesterDataEmpty = semesterData.isEmpty;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'CGPA',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Stack(
        children: [
          ListView.builder(
            itemCount: semesterData.length,
            itemBuilder: (context, index) {
              final semesterName = semesterData.keys.elementAt(index);
              final subjects = semesterData[semesterName];

              double totalCredit = 0.0; // Declare as double instead of int
              subjects?.forEach((subject) {
                totalCredit += subject['credit'];
              });
              return Card(
                child: ExpansionTile(
                  title: Text(semesterName,
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto',
                          color: themeProvider.isDarkMode
                              ? Colors.white
                              : Colors.black)),
                  trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "GPA: ${calculateSemesterGPA(subjects!).toStringAsFixed(2)}",
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Roboto',
                              color: themeProvider.isDarkMode
                                  ? Colors.white
                                  : Colors.black),
                        ),
                        Text("Credit: ${totalCredit.toStringAsFixed(2)}",
                            style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black))
                      ]),
                  childrenPadding: EdgeInsets.all(10),
                  controlAffinity: ListTileControlAffinity.leading,
                  backgroundColor: themeProvider.isDarkMode
                      ? Colors.black12
                      : Colors.blueGrey[50],
                  collapsedBackgroundColor: themeProvider.isDarkMode
                      ? Colors.black45
                      : Colors.blueGrey[50],
                  iconColor:
                      themeProvider.isDarkMode ? Colors.white : Colors.black,
                  textColor:
                      themeProvider.isDarkMode ? Colors.white : Colors.black,
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: subjects.length,
                      itemBuilder: (context, subjectIndex) {
                        final subject = subjects[subjectIndex];
                        return Card(
                          child: ListTile(
                            title: Text(
                              subject['subjectName'],
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            subtitle: Text(
                              'Credit: ${subject['credit']}, GPA: ${subject['gpa']}',
                              style: TextStyle(
                                color: themeProvider.isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            trailing: IconButton(
                              icon: Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete Subject',
                                          style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      content: Text(
                                          'Do you want to Delete This Subject?',
                                          style: TextStyle(
                                            color: themeProvider.isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          )),
                                      actions: <Widget>[
                                        TextButton(
                                          child: Text(
                                            'No',
                                            style: TextStyle(
                                                color: Colors.redAccent),
                                          ),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                        ElevatedButton(
                                          child: Text('Yes'),
                                          onPressed: () async {
                                            _deleteSubject(
                                                semesterName, subjectIndex);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(SnackBar(
                                                    behavior: SnackBarBehavior
                                                        .floating,
                                                    backgroundColor:
                                                        Colors.redAccent,
                                                    content: Text(
                                                      'One Subject is deleted',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontFamily: 'Roboto',
                                                      ),
                                                    )));
                                            Navigator.of(context).pop();
                                          },
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color.fromRGBO(
                                58, 150, 255, 1), // Background color
                          ),
                          onPressed: () {
                            _showAddSubjectDialog(semesterName);
                          },
                          child: Text(
                            'Add Subject',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                        Spacer(),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Colors.redAccent, // Background color
                          ),
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Delete Semester',
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                  content: Text(
                                      'Do you want to Delete The Semester $semesterName?',
                                      style: TextStyle(
                                        color: themeProvider.isDarkMode
                                            ? Colors.white
                                            : Colors.black,
                                      )),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text(
                                        'No',
                                        style:
                                            TextStyle(color: Colors.redAccent),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    ElevatedButton(
                                      child: Text('Yes'),
                                      onPressed: () async {
                                        _deleteSemester(semesterName);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                backgroundColor:
                                                    Colors.redAccent,
                                                content: Text(
                                                  'Semester $semesterName is deleted',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontFamily: 'Roboto',
                                                  ),
                                                )));
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text(
                            'Delete Semester',
                            style: TextStyle(
                              fontFamily: 'Roboto',
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              );
            },
          ),
          Visibility(
            visible: !isSemesterDataEmpty,
            child: Positioned(
              bottom: 16.0,
              left: 16.0,
              child: Container(
                width: 80, // Set the desired width
                height: 80, // Set the desired height
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: themeProvider.isDarkMode
                        ? Colors.white
                        : Color.fromRGBO(58, 150, 255, 1),
                    width: 3.0,
                  ),
                ),
                child: FloatingActionButton(
                  onPressed: null, // Disabled clicking
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        calculateTotalCGPA().toStringAsFixed(2),
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      Text(
                        "Total CGPA",
                        style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  backgroundColor: themeProvider.isDarkMode
                      ? Color.fromRGBO(58, 150, 255, 1)
                      : Colors.white,
                  foregroundColor:
                      themeProvider.isDarkMode ? Colors.white : Colors.black,
                  elevation:
                      0, // Set elevation to 0 to remove the default shadow
                ),
              ),
            ),
          ),
          Visibility(
            visible: !isSemesterDataEmpty,
            child: Positioned(
              bottom: 90.0,
              right: 16.0,
              child: FloatingActionButton(
                backgroundColor: Colors.green,
                onPressed: () {
                  setState(() {
                    saveData();
                  });
                },
                child: Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 28,
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              backgroundColor: Color.fromRGBO(58, 150, 255, 1),
              onPressed: () {
                _showAddSemesterDialog();
              },
              child: Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddSemesterDialog() {
    String semesterName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Semester',
            style: TextStyle(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black),
          ),
          content: TextField(
            style: TextStyle(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black),
            onChanged: (value) {
              semesterName = value;
            },
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Semester Name',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.redAccent),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (semesterName.isNotEmpty) {
                  setState(() {
                    semesterData.putIfAbsent(semesterName, () => []);
                  });
                  Navigator.pop(context);
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSemester(String semesterName) async {
    setState(() {
      semesterData.remove(semesterName);
    });

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({"CGPA": semesterData})
          .then((value) => print('Data Delete successfully Online.'))
          .catchError((error) => print('Failed to Delete data Online: $error'));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String semesterDataJson = json.encode(semesterData);
      await prefs.setString('semesterData', semesterDataJson);
      print('Data Delete successfully Offline.');
    } catch (error) {
      print('Failed to Delete data Offline: $error');
    }
  }

  void _deleteSubject(String semesterName, int subjectIndex) async {
    setState(() {
      semesterData[semesterName]?.removeAt(subjectIndex);
    });

    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({"CGPA": semesterData})
          .then((value) => print('Data Delete successfully Online.'))
          .catchError((error) => print('Failed to Delete data Online: $error'));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String semesterDataJson = json.encode(semesterData);
      await prefs.setString('semesterData', semesterDataJson);
      print('Data Delete successfully Offline.');
    } catch (error) {
      print('Failed to Delete data Offline: $error');
    }
  }

  void _showAddSubjectDialog(String semesterName) {
    String subjectName = '';
    int credit = 0;
    double gpa = 0.0;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text(
              'Add Subject',
              style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : Colors.black),
                  onChanged: (value) {
                    subjectName = value;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Subject Name',
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : Colors.black),
                  onChanged: (value) {
                    credit = int.tryParse(value) ?? 0;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Credit',
                  ),
                  keyboardType: TextInputType.number,
                ),
                SizedBox(height: 16),
                TextField(
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : Colors.black),
                  onChanged: (value) {
                    gpa = double.tryParse(value) ?? 0.0;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'GPA',
                  ),
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  if (subjectName.isNotEmpty && credit > 0 && gpa >= 0.0) {
                    final newSubject = {
                      'subjectName': subjectName,
                      'credit': credit,
                      'gpa': gpa,
                    };

                    setState(() {
                      semesterData[semesterName]?.add(newSubject);
                    });

                    Navigator.pop(context);
                  }
                },
                child: Text('Add'),
              ),
            ],
          ),
        );
      },
    );
  }

  void saveData() async {
    try {
      FirebaseFirestore.instance
          .collection('users')
          .doc(userID)
          .update({
            "CGPA": semesterData,
          })
          .then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.green,
              content: Text(
                'Data saved successfully',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Roboto',
                ),
              ))))
          .catchError(
              (error) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.redAccent,
                  content: Text(
                    'Failed to save data',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                    ),
                  ))));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String semesterDataJson = json.encode(semesterData);
      await prefs.setString('semesterData', semesterDataJson);
    } catch (error) {}
  }
}
