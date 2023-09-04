import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jukto/theme/theme.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Event {
  final String title;
  final String description;
  final DateTime date;

  Event(this.title, this.description, this.date);
}

class EventSchedulerPage extends StatefulWidget {
  @override
  _EventSchedulerPageState createState() => _EventSchedulerPageState();
}

class _EventSchedulerPageState extends State<EventSchedulerPage> {
  List<Event> events = [];
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadEvents();
  }

  void loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventList = prefs.getStringList('events');
    if (eventList != null) {
      setState(() {
        events = eventList.map((e) {
          final parts = e.split('|');
          final title = parts[0];
          final description = parts[1];
          final date =
              DateTime.parse(parts[2]); // Parse the date from the string
          return Event(title, description, date);
        }).toList();
      });
    }
  }

  void saveEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventStrings = events
        .map((e) => '${e.title}|${e.description}|${e.date.toIso8601String()}')
        .toList();
    prefs.setStringList('events', eventStrings);
  }

  void addEvent(Event event) {
    setState(() {
      events.add(event);
      saveEvents();
    });
  }

  void deleteEvent(int index) {
    setState(() {
      events.removeAt(index);
      saveEvents();
    });
  }

  Future<void> _showAddEventDialog(BuildContext context) async {
    String newDay = '';
    DateTime selectedDate = DateTime.now();
    String initialDateValue = newDay.isNotEmpty
        ? newDay.split(' ')[0]
        : DateFormat('dd-MM-yyyy').format(DateTime.now());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Add Event',
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
                decoration: InputDecoration(
                  hintText: 'Title',
                  border: OutlineInputBorder(),
                ),
                controller: _titleController,
              ),
              TextField(
                style: TextStyle(
                    color: Provider.of<ThemeProvider>(context).isDarkMode
                        ? Colors.white
                        : Colors.black),
                decoration: InputDecoration(
                  hintText: 'Description',
                  border: OutlineInputBorder(),
                ),
                controller: _descriptionController,
              ),
              GestureDetector(
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(newDay.isEmpty ? 'Select a date' : newDay,
                          style: TextStyle(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
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
                    String dayOfWeek = DateFormat('EEEE').format(pickedDate);

                    setState(() {
                      newDay = '$formattedDate $dayOfWeek';
                      initialDateValue = newDay.split(' ')[0];
                      _dateController.text = initialDateValue;
                      selectedDate = pickedDate; // Update the selectedDate here
                    });
                  }
                },
              ),
            ],
          ),
          actions: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    _titleController.clear();
                    _descriptionController.clear();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.redAccent),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final title = _titleController.text;
                    final description = _descriptionController.text;
                    if (title.isNotEmpty) {
                      addEvent(Event(title, description, selectedDate));
                      _titleController.clear();
                      _descriptionController.clear();
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Event Scheduler',
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
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  child: ListTile(
                    title: Text(
                      event.title,
                      style: TextStyle(
                          color: Provider.of<ThemeProvider>(context).isDarkMode
                              ? Colors.white
                              : Colors.black),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          event.description,
                          style: TextStyle(
                              color:
                                  Provider.of<ThemeProvider>(context).isDarkMode
                                      ? Colors.white
                                      : Colors.black),
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('|'),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          'Date: ${DateFormat('dd-MM-yyyy EEEE').format(event.date)}', // Format the date here
                          style: TextStyle(
                            color:
                                Provider.of<ThemeProvider>(context).isDarkMode
                                    ? Colors.white
                                    : Colors.black,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.redAccent,
                      ),
                      onPressed: () => deleteEvent(index),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Color.fromRGBO(58, 150, 255, 1),
        onPressed: () => _showAddEventDialog(context),
        label: const Text(
          'Add Event',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
