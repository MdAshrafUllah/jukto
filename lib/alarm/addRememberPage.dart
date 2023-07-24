import 'package:flutter/material.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';

class AddRememberPage extends StatefulWidget {
  @override
  _AddRememberPageState createState() => _AddRememberPageState();
}

class _AddRememberPageState extends State<AddRememberPage> {
  final List<String> _daysOfWeek = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];
  final Set<String> _selectedDays = {};
  TimeOfDay? _selectedTime;
  String _subject = '';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add Reminder',
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
                        activeColor: Color.fromRGBO(58, 150, 255, 1),
                        value: _selectedDays.contains(day),
                        onChanged: (checked) {
                          setState(() {
                            if (checked != null && checked) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
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
                decoration: InputDecoration(
                  labelText: 'Subject',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) => setState(() => _subject = value),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Background color
                ),
                onPressed: () async {
                  final selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _selectedTime = selectedTime;
                    });
                  }
                },
                child: Text(_selectedTime != null
                    ? 'Time: ${_selectedTime!.format(context)}'
                    : 'Select Time'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitClassRoutine,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submitClassRoutine() {
    final newRoutine = ClassRoutine(
        days: _selectedDays.toList(), time: _selectedTime, subject: _subject);

    Navigator.pop(context, newRoutine);
  }
}

class ClassRoutine {
  final List<String> days;
  final TimeOfDay? time;
  final String subject;

  ClassRoutine({required this.days, required this.time, required this.subject});
}
