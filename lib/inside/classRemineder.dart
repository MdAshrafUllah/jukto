import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ClassReminderPage extends StatefulWidget {
  @override
  _ClassReminderPageState createState() => _ClassReminderPageState();
}

class _ClassReminderPageState extends State<ClassReminderPage> {
  FlutterLocalNotificationsPlugin notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  String alarmText = '';

  Future<void> onSelectNotification(String payload) async {
    if (payload != null) {
      debugPrint('notification payload: $payload');
    }
  }

  Future<void> scheduleNotification() async {
    var scheduledNotificationDateTime =
        DateTime.now().add(Duration(seconds: 5));

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await notificationsPlugin.zonedSchedule(
      0,
      'Medicine Reminder',
      'Alarm set for: $alarmText',
      tz.TZDateTime.now(tz.local).add(const Duration(seconds: 5)),
      platformChannelSpecifics,
      payload: 'notification_payload',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  void showNotification() async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
      'channel_id',
      'channel_name',
      importance: Importance.max,
      priority: Priority.high,
    );
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
    );

    await notificationsPlugin.show(
      0,
      'Medicine Reminder',
      'Alarm set for: $alarmText',
      platformChannelSpecifics,
      payload: 'notification_payload',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          scheduleNotification();
        },
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
        backgroundColor: Theme.of(context).accentColor,
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            AppBar(
              title: Text('Medicine Reminder'),
              backgroundColor: Theme.of(context).primaryColor,
            ),
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    alarmText = value;
                  });
                },
                decoration: InputDecoration(
                  labelText: 'Alarm Text',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
