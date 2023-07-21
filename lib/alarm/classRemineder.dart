import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'add_class_page.dart';
import 'edit_class_page.dart';

class ClassRoutinePage extends StatefulWidget {
  @override
  _ClassRoutinePageState createState() => _ClassRoutinePageState();
}

class _ClassRoutinePageState extends State<ClassRoutinePage> {
  final List<ClassRoutine> _submittedRoutines = [];

  final List<String> _daysOfWeek = [
    'Sat',
    'Sun',
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Class Routine Submission'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _submittedRoutines.length,
              itemBuilder: (context, index) {
                final routine = _submittedRoutines[index];
                return Card(
                  color: Colors.white70,
                  child: ListTile(
                    title: Text(_getTitle(routine.days)),
                    subtitle: Text(
                        'Time: ${routine.time!.format(context)} | Subject: ${routine.subject}'),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteRoutine(index);
                      },
                    ),
                    onTap: () async {
                      final updatedRoutine = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditClassPage(routine: routine),
                        ),
                      );
                      if (updatedRoutine != null) {
                        _updateRoutine(index, updatedRoutine);
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddClassPage()),
          );
          if (result != null) {
            _submitRoutine(result.days, result.time, result.subject);
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }

  String _getTitle(List<String> days) {
    if (days.length == 7) {
      return 'Everyday';
    } else {
      return 'Days: ${days.join(', ')}';
    }
  }

  void _submitRoutine(List<String> days, TimeOfDay? time, String subject) {
    final newRoutine = ClassRoutine(days: days, time: time, subject: subject);

    setState(() {
      _submittedRoutines.add(newRoutine);
    });
    _scheduleNotification(newRoutine);
  }

  void _updateRoutine(int index, ClassRoutine updatedRoutine) {
    setState(() {
      _submittedRoutines[index] = updatedRoutine;
    });

    _scheduleNotification(updatedRoutine);
  }

  void _deleteRoutine(int index) {
    setState(() {
      _submittedRoutines.removeAt(index);
    });
  }
}

class ClassRoutine {
  final List<String> days;
  final TimeOfDay? time;
  final String subject;

  ClassRoutine({required this.days, required this.time, required this.subject});
}

Future<void> _scheduleNotification(ClassRoutine routine) async {
  final int id = DateTime.now().millisecondsSinceEpoch % (1 << 31);

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'your_channel_id',
    'your_channel_name',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: false,
    additionalFlags: Int32List.fromList([4]),
  );

  NotificationDetails platformChannelSpecifics =
      NotificationDetails(android: androidPlatformChannelSpecifics);

  final TimeOfDay timeOfDay = routine.time!;
  final DateTime now = DateTime.now();
  final DateTime scheduledDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    timeOfDay.hour,
    timeOfDay.minute,
  );

  // Convert the DateTime to TZDateTime using the local time zone
  final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
    scheduledDateTime,
    tz.local,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    id,
    'Class Reminder',
    'It\'s time for ${routine.subject} class.',
    scheduledTime,
    platformChannelSpecifics,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    androidAllowWhileIdle: true,
    payload: 'class_payload_$id',
  );
}
