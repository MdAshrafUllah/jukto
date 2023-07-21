import 'package:flutter/material.dart';

class AddClassPage extends StatefulWidget {
  @override
  _AddClassPageState createState() => _AddClassPageState();
}

class _AddClassPageState extends State<AddClassPage> {
  final List<String> _daysOfWeek = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];
  final Set<String> _selectedDays = {};
  TimeOfDay? _selectedTime;
  String _subject = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Class Routine'),
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
            ElevatedButton(
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
            TextFormField(
              decoration: InputDecoration(labelText: 'Subject'),
              onChanged: (value) => setState(() => _subject = value),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitClassRoutine,
              child: Text('Submit'),
            ),
          ],
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
