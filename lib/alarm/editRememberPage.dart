import 'package:flutter/material.dart';

import 'reminederPage.dart';

class EditRememberPage extends StatefulWidget {
  final ClassRoutine routine;

  EditRememberPage({required this.routine});

  @override
  _EditRememberPageState createState() => _EditRememberPageState();
}

class _EditRememberPageState extends State<EditRememberPage> {
  late List<String> _days;
  late TimeOfDay _time;
  late String _subject;

  // Define the list of days here
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Edit Reminder',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
      ),
      body: Padding(
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
            ElevatedButton(
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
            TextFormField(
              initialValue: _subject,
              decoration: InputDecoration(labelText: 'Subject'),
              onChanged: (value) => setState(() => _subject = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateRoutine,
              child: Text('Update'),
            ),
          ],
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
