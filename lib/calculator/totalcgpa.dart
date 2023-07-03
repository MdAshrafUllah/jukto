import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class totalCGPApage extends StatefulWidget {
  const totalCGPApage({Key? key}) : super(key: key);

  @override
  _totalCGPApageState createState() => _totalCGPApageState();
}

class _totalCGPApageState extends State<totalCGPApage> {
  Map<String, List<List<Widget>>> semesterData = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Total CGPA',
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: semesterData.length,
        itemBuilder: (context, index) {
          final semester = semesterData.keys.elementAt(index);
          final subjectRows = semesterData[semester]!;

          return Column(
            children: [
              Row(
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 20, top: 20),
                    padding: EdgeInsets.only(left: 10),
                    height: 25,
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(
                        width: 2,
                        color: Color.fromRGBO(162, 158, 158, 1),
                      ),
                    ),
                    child: Text(
                      semester,
                      style: TextStyle(
                        color: Colors.black,
                        fontFamily: 'Roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Container(
                margin: EdgeInsets.only(left: 20, right: 20),
                child: Column(
                  children: [
                    for (var i = 0; i < subjectRows.length; i++)
                      Column(
                        children: [
                          Container(
                            height: 25,
                            child: Row(children: subjectRows[i]),
                          ),
                          SizedBox(height: 10), // Adjust the height as needed
                        ],
                      ),
                    SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          height: 30,
                          child: TextButton(
                            onPressed: () {
                              addSubjectRow(semester);
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.blue,
                              minimumSize: Size(100, 30),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Add Subject',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Colors.blue,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.all(5),
                          height: 30,
                          child: TextButton(
                            onPressed: () {
                              deletedSemesterDialog(context, semester);
                            },
                            style: TextButton.styleFrom(
                              primary: Colors.redAccent,
                              minimumSize: Size(100, 30),
                              padding: EdgeInsets.zero,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                  size: 18,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Deleted Semester',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(
                              width: 1.0,
                              color: Colors.redAccent,
                            ),
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addSemesterDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void addSemesterDialog(BuildContext context) {
    TextEditingController semesterController = TextEditingController();

    AlertDialog alertDialog = AlertDialog(
      title: Text("Add Semester"),
      content: TextField(
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
        ],
        controller: semesterController,
        decoration: InputDecoration(
          labelText: "Semester",
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          child: Text("Cancel"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Add"),
          onPressed: () {
            String semester = semesterController.text.trim();
            if (semester.isNotEmpty) {
              addSubjectRow(semester);
              Navigator.of(context).pop();
            }
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  void deletedSemesterDialog(BuildContext context, String semester) {
    AlertDialog alertDialog = AlertDialog(
      title: Text("Delete Semester"),
      content:
          Text("Are you sure you want to delete the semester '$semester'?"),
      actions: [
        TextButton(
          child: Text("No"),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text("Yes"),
          onPressed: () {
            setState(() {
              semesterData.remove(semester);
            });
            Navigator.of(context).pop();
          },
        ),
      ],
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
  }

  void addSubjectRow(String semester) {
    setState(() {
      if (!semesterData.containsKey(semester)) {
        semesterData[semester] = [];
      }
      semesterData[semester]!.add([
        Expanded(
          child: Container(
            width: 150,
            child: TextField(
              keyboardType: TextInputType.text,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[a-zA-Z]'))
              ],
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Subject Name',
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            width: 150,
            child: TextField(
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp('[A-F,a-f,+-]'))
              ],
              keyboardType: TextInputType.text,
              textCapitalization: TextCapitalization.characters,
              style: TextStyle(fontSize: 12),
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'GPA',
              ),
            ),
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: Container(
            width: 150,
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                          RegExp(r'^([0-3](\.[0-9]{1,2})?|4(\.00?)?)$')),
                    ],
                    style: TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Point',
                    ),
                  ),
                ),
                SizedBox(width: 10),
                IconButton(
                  padding: EdgeInsets.only(top: 0),
                  icon: Icon(
                    Icons.cancel,
                    color: Colors.redAccent,
                  ),
                  onPressed: () {
                    setState(() {
                      semesterData[semester]!.removeLast();
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ]);
    });
  }
}
