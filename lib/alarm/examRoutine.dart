import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class ExamRoutine {
  String date; // Store the date in "dd-MM-yyyy" format
  String day; // Store the day of the week
  String subject;
  TimeOfDay time;

  ExamRoutine({
    required this.date,
    required this.day,
    required this.subject,
    required this.time,
  });

  // Convert the ExamRoutine object to a map for serialization
  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'day': day,
      'subject': subject,
      'time': '${time.hour}:${time.minute}',
    };
  }

  // Create a ExamRoutine object from a map
  factory ExamRoutine.fromMap(Map<String, dynamic> map) {
    return ExamRoutine(
      date: map['date'],
      day: map['day'],
      subject: map['subject'],
      time: TimeOfDay(
        hour: int.parse(map['time'].split(':')[0]),
        minute: int.parse(map['time'].split(':')[1]),
      ),
    );
  }

  // Format the time to 12-hour format (AM/PM)
  String formattedTime() {
    final now = DateTime.now();
    final dateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    return DateFormat.jm().format(dateTime);
  }
}

class ExamRoutinePage extends StatefulWidget {
  @override
  _ExamRoutinePageState createState() => _ExamRoutinePageState();
}

class _ExamRoutinePageState extends State<ExamRoutinePage> {
  List<ExamRoutine> examRoutine = [];
  TextEditingController _dateController = TextEditingController();
  String newDay = '';

  List<String> weekDays = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  // String? newDay; // Changed to allow null value
  String newSubject = '';
  TimeOfDay newTime = TimeOfDay.now();

  @override
  void initState() {
    super.initState();
    _loadExamRoutine();
    _dateController.text = newDay ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Exam Routine',
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
          rows: _buildDataRows(),
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

  List<DataRow> _buildDataRows() {
    return examRoutine.map((routine) {
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
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                          )),
                      content: Text('Do you want to Delete This Subject?',
                          style: TextStyle(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
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
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
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
    }).toList();
  }

  void _showAddSubjectDialog(BuildContext context) {
    newDay = ''; // Set initial value to empty string
    newSubject = '';
    newTime = TimeOfDay.now();

    // Split the newDay string to get the "dd-MM-yyyy" part
    String initialDateValue = newDay.isNotEmpty
        ? newDay.split(' ')[0] // Get the "dd-MM-yyyy" part
        : DateFormat('dd-MM-yyyy').format(DateTime.now());

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
                GestureDetector(
                  child: InputDecorator(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Date',
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(newDay.isEmpty ? 'Select a date' : newDay,
                            style: TextStyle(
                                color: Provider.of<ThemeProvider>(context)
                                        .isDarkMode
                                    ? Colors.white
                                    : Colors.black)),
                        Icon(Icons.calendar_today),
                      ],
                    ),
                  ),
                  onTap: () async {
                    FocusScope.of(context).requestFocus(new FocusNode());
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: newDay.isNotEmpty
                          ? DateFormat('dd-MM-yyyy').parse(newDay.split(' ')[0])
                          : DateTime.now(),
                      firstDate: DateTime(DateTime.now().year - 1),
                      lastDate: DateTime(DateTime.now().year + 1),
                    );

                    if (pickedDate != null) {
                      String formattedDate =
                          DateFormat('dd-MM-yyyy').format(pickedDate);
                      String dayOfWeek = DateFormat('EEEE')
                          .format(pickedDate); // Get the day of the week

                      setState(() {
                        newDay = '$formattedDate $dayOfWeek';
                        // Split the newDay string to get the "dd-MM-yyyy" part
                        initialDateValue = newDay.split(' ')[0];
                        _dateController.text =
                            initialDateValue; // Update the controller value with "dd-MM-yyyy"
                      });
                    }
                  },
                ),
                TextFormField(
                  style: TextStyle(
                      color: Provider.of<ThemeProvider>(context).isDarkMode
                          ? Colors.white
                          : Colors.black),
                  decoration: InputDecoration(
                    hintText: 'Enter subject',
                    border: OutlineInputBorder(),
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
                child:
                    Text('Cancel', style: TextStyle(color: Colors.redAccent)),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              ElevatedButton(
                child: Text('Add'),
                onPressed: () {
                  setState(() {
                    if (newDay.isNotEmpty && newSubject.isNotEmpty) {
                      // Check if the subject already exists in the routine
                      ExamRoutine? existingSubject =
                          examRoutine.firstWhereOrNull(
                        (routine) =>
                            routine.day == newDay &&
                            routine.subject == newSubject,
                      );

                      if (existingSubject != null) {
                        // Subject with the same name already exists, update the time
                        existingSubject.time = newTime;
                      } else {
                        // Add as a new entry or group under the same name
                        List<ExamRoutine> sameNamedSubjects = examRoutine
                            .where((routine) => routine.subject == newSubject)
                            .toList();

                        if (sameNamedSubjects.isNotEmpty) {
                          // Group under the same name
                          sameNamedSubjects.forEach((subject) {
                            subject.day = subject.day + "\n" + newDay;
                          });
                          examRoutine.add(ExamRoutine(
                            date: initialDateValue,
                            day: newDay,
                            subject: newSubject,
                            time: newTime,
                          ));
                        } else {
                          // Add as a new entry
                          examRoutine.add(ExamRoutine(
                            date: initialDateValue,
                            day: newDay,
                            subject: newSubject,
                            time: newTime,
                          ));
                        }
                      }

                      // Save the updated ExamRoutine list to storage
                      _saveExamRoutine();
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

  void _showEditSubjectDialog(BuildContext context, ExamRoutine routine) {
    String updatedSubject = routine.subject;
    TimeOfDay updatedTime = routine.time;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Subject and Time',
              style: TextStyle(
                  color: Provider.of<ThemeProvider>(context).isDarkMode
                      ? Colors.white
                      : Colors.black)),
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
                    hintText: 'Enter subject', border: OutlineInputBorder()),
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

                // Save the updated ExamRoutine list to storage
                _saveExamRoutine();
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: Colors.green,
                    content: Text(
                      'Exam Routine is Updated',
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

  void _deleteSubject(ExamRoutine routine) {
    setState(() {
      examRoutine.remove(routine);

      // Save the updated ExamRoutine list to storage
      _saveExamRoutine();
    });
  }

  Future<void> _saveExamRoutine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<Map<String, dynamic>> serializedData = examRoutine.map((routine) {
      // Separate the "date" and "day" fields before saving to shared preferences
      String date = routine.date.split(' ')[0];
      String day = routine.day;
      return {
        'date': date,
        'day': day,
        'subject': routine.subject,
        'time': '${routine.time.hour}:${routine.time.minute}',
      };
    }).toList();

    // Convert the list of ExamRoutine objects to a JSON string
    String jsonData = jsonEncode(serializedData);

    await prefs.setString('ExamRoutine', jsonData);
  }

  Future<void> _loadExamRoutine() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? serializedData = prefs.getString('ExamRoutine');
    if (serializedData != null && serializedData.isNotEmpty) {
      try {
        List<dynamic> data = jsonDecode(serializedData);
        List<ExamRoutine> loadedExamRoutine = data
            .map((item) => ExamRoutine.fromMap(item))
            .toList()
            .cast<
                ExamRoutine>(); // Add .cast<ExamRoutine>() to ensure correct data type

        setState(() {
          examRoutine = loadedExamRoutine;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.red,
            content: Text(
              'Error loading ExamRoutine data',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Roboto',
              ),
            )));

        // Handle the error as needed, e.g., clear the invalid data from shared preferences
        await prefs.remove('ExamRoutine');
      }
    }
  }
}

void main() {
  runApp(MaterialApp(
    home: ExamRoutinePage(),
  ));
}
