import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

import '../theme/theme.dart';

class ClassRoutine {
  String day;
  String subject;
  TimeOfDay time;

  ClassRoutine({required this.day, required this.subject, required this.time});

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'subject': subject,
      'time': '${time.hour}:${time.minute}',
    };
  }

  factory ClassRoutine.fromMap(Map<String, dynamic> map) {
    return ClassRoutine(
      day: map['day'],
      subject: map['subject'],
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
    );
  }

  String formattedTime() {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return DateFormat.jm().format(dateTime);
  }
}

class ClassRoutinePage extends StatefulWidget {
  @override
  _ClassRoutinePageState createState() => _ClassRoutinePageState();
}

class _ClassRoutinePageState extends State<ClassRoutinePage> {
  List<ClassRoutine> classRoutine = [];

  List<String> weekDays = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  String? newDay;
  String newSubject = '';
  TimeOfDay newTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadClassRoutine();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadClassRoutine();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Class Routine',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
          columns: [
            DataColumn(
                label: Text('Day',
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black))),
            DataColumn(
                label: Text('Time',
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black))),
            DataColumn(
                label: Text('Subject',
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black))),
            DataColumn(
                label: Text('Action',
                    style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black))),
          ],
          rows: classRoutine.map((routine) {
            return DataRow(cells: [
              DataCell(Text(routine.day)),
              DataCell(Text(routine.formattedTime())),
              DataCell(Text(routine.subject)),
              DataCell(Row(
                children: [
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: Color.fromRGBO(58, 150, 255, 1),
                    ),
                    onPressed: () {
                      _showEditSubjectDialog(context, routine);
                    },
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
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
                            content: Text('Do you want to Delete This Subject?',
                                style: TextStyle(
                                  color: themeProvider.isDarkMode
                                      ? Colors.white
                                      : Colors.black,
                                )),
                            actions: <Widget>[
                              TextButton(
                                child: Text(
                                  'No',
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                              ElevatedButton(
                                child: Text('Yes'),
                                onPressed: () async {
                                  _deleteSubject(routine);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(SnackBar(
                                          behavior: SnackBarBehavior.floating,
                                          backgroundColor: Colors.redAccent,
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
                ],
              )),
            ]);
          }).toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        onPressed: () {
          _showAddSubjectDialog(context);
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context) {
    newDay = null;
    newSubject = '';
    newTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) {
        return SingleChildScrollView(
          child: AlertDialog(
            title: Text('Add New Subject',
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: newDay,
                  items: weekDays.map((day) {
                    return DropdownMenuItem<String>(
                      value: day,
                      child: Text(day,
                          style: TextStyle(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : Colors.black)),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      newDay = value!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Select day',
                    hintText: 'Select a day',
                  ),
                ),
                TextFormField(
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : Colors.black),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Enter subject',
                  ),
                  onChanged: (value) {
                    newSubject = value;
                  },
                ),
                ListTile(
                  title: Text('Select Time',
                      style: TextStyle(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.white
                              : Colors.black)),
                  subtitle: Text(
                      '${newTime.hour}:${newTime.minute.toString().padLeft(2, '0')}',
                      style: TextStyle(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.white
                              : Colors.black)),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: newTime,
                    );
                    if (pickedTime != null) {
                      setState(() {
                        newTime = pickedTime;
                      });
                    }
                  },
                ),
              ],
            ),
            actions: <Widget>[
              TextButton(
                child: Text(
                  'Cancel',
                  style: TextStyle(color: Colors.redAccent),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    if (newDay != null && newSubject.isNotEmpty) {
                      ClassRoutine? existingSubject =
                          classRoutine.firstWhereOrNull(
                        (routine) =>
                            routine.day == newDay &&
                            routine.subject == newSubject,
                      );

                      if (existingSubject != null) {
                        existingSubject.time = newTime;
                      } else {
                        List<ClassRoutine> sameNamedSubjects = classRoutine
                            .where((routine) => routine.subject == newSubject)
                            .toList();

                        if (sameNamedSubjects.isNotEmpty) {
                          sameNamedSubjects.forEach((subject) {
                            subject.day = subject.day + "\n" + newDay!;
                          });
                          classRoutine.add(ClassRoutine(
                            day: newDay!,
                            subject: newSubject,
                            time: newTime,
                          ));

                          classRoutine.sort((a, b) => weekDays
                              .indexOf(a.day)
                              .compareTo(weekDays.indexOf(b.day)));
                        } else {
                          classRoutine.add(ClassRoutine(
                            day: newDay!,
                            subject: newSubject,
                            time: newTime,
                          ));

                          classRoutine.sort((a, b) => weekDays
                              .indexOf(a.day)
                              .compareTo(weekDays.indexOf(b.day)));
                        }

                        _saveClassRoutine();
                      }
                    }
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showEditSubjectDialog(BuildContext context, ClassRoutine routine) {
    String updatedSubject = routine.subject;
    TimeOfDay updatedTime = routine.time;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Edit Subject and Time',
            style: TextStyle(
                color: Provider.of<ThemeProvider>(context).isDarkMode
                    ? Colors.white
                    : Colors.black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black),
                onChanged: (value) {
                  updatedSubject = value;
                },
                decoration: InputDecoration(
                  hintText: 'Enter subject',
                  border: OutlineInputBorder(),
                ),
                controller: TextEditingController(text: routine.subject),
              ),
              ListTile(
                title: Text('Select Time',
                    style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.white
                            : Colors.black)),
                subtitle: Text(
                    '${updatedTime.hour}:${updatedTime.minute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                        color: Provider.of<ThemeProvider>(context).isDarkMode
                            ? Colors.white
                            : Colors.black)),
                onTap: () async {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  final pickedTime = await showTimePicker(
                    context: context,
                    initialTime: updatedTime,
                  );
                  if (pickedTime != null) {
                    setState(() {
                      updatedTime = pickedTime;
                    });
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.redAccent)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              child: Text('Update'),
              onPressed: () {
                setState(() {
                  routine.subject = updatedSubject;
                  routine.time = updatedTime;
                });

                _saveClassRoutine();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    content: Text(
                      'Class Routine is Updated',
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
  }

  void _deleteSubject(ClassRoutine routine) {
    setState(() {
      classRoutine.remove(routine);

      _saveClassRoutine();
    });
  }

  Future<void> _saveClassRoutine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> serializedData =
        classRoutine.map((routine) => routine.toMap()).toList();
    String jsonString = jsonEncode(serializedData);
    await prefs.setString('classRoutine', jsonString);
  }

  Future<void> _loadClassRoutine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serializedData = prefs.getString('classRoutine');
    if (serializedData != null && serializedData.isNotEmpty) {
      try {
        List<dynamic> data = jsonDecode(serializedData);
        List<ClassRoutine> loadedClassRoutine =
            data.map((item) => ClassRoutine.fromMap(item)).toList();

        loadedClassRoutine.sort((a, b) =>
            weekDays.indexOf(a.day).compareTo(weekDays.indexOf(b.day)));

        setState(() {
          classRoutine = loadedClassRoutine;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.redAccent,
            content: Text(
              'Error loading class routine data',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            )));
      }
    }
  }
}
