import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:jukto/theme/theme.dart';

import 'remineder_page.dart';

class EditRememberPage extends StatefulWidget {
  final ClassRoutine routine;

  const EditRememberPage({super.key, required this.routine});

  @override
  EditRememberPageState createState() => EditRememberPageState();
}

class EditRememberPageState extends State<EditRememberPage> {
  late List<String> _days;
  late TimeOfDay _time;
  late String _subject;

  final List<String> _daysOfWeek = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];

  @override
  void initState() {
    super.initState();
    _days = List.from(widget.routine.days);
    _time = widget.routine.time!;
    _subject = widget.routine.subject;
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit Reminder',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: const IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Wrap(
                spacing: 8,
                children: _daysOfWeek.map((day) {
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Checkbox(
                        activeColor: const Color.fromRGBO(58, 150, 255, 1),
                        value: _days.contains(day),
                        onChanged: (checked) {
                          setState(() {
                            if (checked != null && checked) {
                              _days.add(day);
                            } else {
                              _days.remove(day);
                            }
                          });
                        },
                      ),
                      Text(day),
                    ],
                  );
                }).toList(),
              ),
              TextFormField(
                style: TextStyle(
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black),
                initialValue: _subject,
                decoration: const InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _subject = value),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: _time,
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _time = selectedTime;
                    });
                  }
                },
                child: Text('Time: ${_time.format(context)}'),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_subject.isNotEmpty && _days.isNotEmpty) {
                    _updateRoutine();
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        behavior: SnackBarBehavior.floating,
                        backgroundColor: Colors.redAccent,
                        content: Text(
                          'All Fields Are Required to Update Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Roboto',
                          ),
                        )));
                  }
                },
                child: const Text('Update'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _updateRoutine() {
    final updatedRoutine =
        ClassRoutine(days: _days, time: _time, subject: _subject);

    Navigator.pop(context, updatedRoutine);
  }
}
