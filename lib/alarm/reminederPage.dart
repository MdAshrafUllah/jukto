import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'addRememberPage.dart';
import 'editRememberPage.dart';

class ReminderPage extends StatefulWidget {
  @override
  _ReminderPageState createState() => _ReminderPageState();
}

class _ReminderPageState extends State<ReminderPage> {
  final List<ClassRoutine> _submittedRoutines = [];
  final List<String> _daysOfWeek = [
    "Saturday",
    "Sunday",
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
  ];
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    _loadReminders();
    _initializeNotifications();
  }

  Future<void> _loadReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final savedReminders = prefs.getStringList('reminders');
    if (savedReminders != null) {
      setState(() {
        _submittedRoutines.clear();
        _submittedRoutines.addAll(savedReminders
            .map((jsonString) => ClassRoutine.fromJson(jsonDecode(jsonString)))
            .toList());
      });
    }
  }

  Future<void> _saveReminders() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final remindersJson = _submittedRoutines
        .map((reminder) => jsonEncode(reminder.toJson()))
        .toList();
    await prefs.setStringList('reminders', remindersJson);
  }

  Future<void> _initializeNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Reminder Setup',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
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
                  color: themeProvider.isDarkMode
                      ? Colors.black12
                      : Colors.blueGrey[50],
                  child: ListTile(
                    title: Text(
                      _getTitle(routine.days),
                      style: TextStyle(
                        color: themeProvider.isDarkMode
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                    subtitle: Text(
                      'Time: ${routine.time!.format(context)} | Subject: ${routine.subject}',
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
                        _deleteRoutine(index);
                      },
                    ),
                    onTap: () async {
                      final updatedRoutine = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditRememberPage(routine: routine),
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
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddRememberPage()),
          );
          if (result != null) {
            _submitRoutine(result.days, result.time, result.subject);
          }
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
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
    _saveReminders();
  }

  void _updateRoutine(int index, ClassRoutine updatedRoutine) {
    setState(() {
      _submittedRoutines[index] = updatedRoutine;
    });

    _scheduleNotification(updatedRoutine);
    _saveReminders();
  }

  void _deleteRoutine(int index) {
    setState(() {
      _submittedRoutines.removeAt(index);
    });
    _saveReminders();
  }

  Future<void> _scheduleNotification(ClassRoutine routine) async {
    final int id = DateTime.now().millisecondsSinceEpoch % (1 << 31);

    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();

    AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: false,
      additionalFlags: Int32List.fromList([4]),
    );

    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    final TimeOfDay timeOfDay = routine.time!;
    final DateTime now = DateTime.now();
    final String day = DateFormat('EEEE').format(DateTime.now());
    List<int> selectedDays = routine.days
        .map((day) => _daysOfWeek.indexOf(day))
        .toList()
        .cast<int>();

    for (var selectedDay in selectedDays) {
      if (_daysOfWeek[selectedDay] == day) {
        int dayOffset = selectedDay - now.weekday;
        if (dayOffset < 0) {
          dayOffset += 7;
        }

        final DateTime scheduledDateTime = DateTime(
          now.year,
          now.month,
          now.day + dayOffset,
          timeOfDay.hour,
          timeOfDay.minute,
        );

        final tz.TZDateTime scheduledTime = tz.TZDateTime.from(
          scheduledDateTime,
          tz.local,
        );

        await flutterLocalNotificationsPlugin.zonedSchedule(
          id + selectedDay,
          'Reminder',
          'It\'s time for ${routine.subject}.',
          scheduledTime,
          platformChannelSpecifics,
          androidAllowWhileIdle: true,
          payload: 'class_payload_${id + selectedDay}',
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.time,
        );
      }
    }
  }
}

class ClassRoutine {
  final List<String> days;
  final TimeOfDay? time;
  final String subject;

  ClassRoutine({required this.days, required this.time, required this.subject});

  Map<String, dynamic> toJson() {
    return {
      'days': days,
      'time': time!.hour * 60 + time!.minute,
      'subject': subject,
    };
  }

  factory ClassRoutine.fromJson(Map<String, dynamic> json) {
    return ClassRoutine(
      days: (json['days'] as List).map((day) => day.toString()).toList(),
      time: TimeOfDay(
        hour: json['time'] ~/ 60,
        minute: json['time'] % 60,
      ),
      subject: json['subject'],
    );
  }
}
