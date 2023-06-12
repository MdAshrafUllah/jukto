import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class totalCGPApage extends StatefulWidget {
  const totalCGPApage({super.key});

  @override
  State<totalCGPApage> createState() => _totalCGPApageState();
}

class _totalCGPApageState extends State<totalCGPApage> {
  List<String> semesters = [];
  List<Map<String, String>> tableData = [];

  void addTableRow(String subject, String credit, String grade) {
    setState(() {
      tableData.add({
        'Subject': subject,
        'Credit': credit,
        'Grade': grade,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () async {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 30,
            )),
        title: const Text(
          "Jukto",
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Roboto',
            fontSize: 40,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color.fromRGBO(58, 150, 255, 1),
        iconTheme: IconThemeData(color: Colors.white, size: 35.0),
        actions: <Widget>[
          Builder(
            builder: (BuildContext context) {
              return IconButton(
                icon: Icon(Icons.menu),
                color: Colors.white,
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),
      endDrawer: Drawer(),
      body: ListView.builder(
          itemCount: semesters.length,
          itemBuilder: (context, index) {
            final semester = semesters[index];
            return Column(
              children: [
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      margin: EdgeInsets.only(left: 20, top: 20),
                      padding: EdgeInsets.only(
                        left: 10,
                      ),
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
                        style: const TextStyle(
                          color: Colors.black,
                          fontFamily: 'Roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: 10,
                ),
                Container(
                  margin: EdgeInsets.only(left: 20, right: 20),
                  child: Table(
                    defaultColumnWidth: FixedColumnWidth(120.0),
                    border: TableBorder.all(
                        color: Colors.black,
                        style: BorderStyle.solid,
                        width: 2),
                    children: [
                      TableRow(children: [
                        Column(children: [
                          Text('Subject Name', style: TextStyle(fontSize: 18.0))
                        ]),
                        Column(children: [
                          Text('Credit', style: TextStyle(fontSize: 18.0))
                        ]),
                        Column(children: [
                          Text('Greade', style: TextStyle(fontSize: 18.0))
                        ]),
                      ]),
                      TableRow(children: [
                        Column(children: [Text('')]),
                        Column(children: [Text('')]),
                        Column(children: [Text('')]),
                      ]),
                      TableRow(children: [
                        Column(children: [Text('')]),
                        Column(children: [Text('')]),
                        Column(children: [Text('')]),
                      ]),
                      TableRow(children: [
                        Column(children: [Text('')]),
                        Column(children: [Text('')]),
                        Column(children: [Text('')]),
                      ]),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.delete,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    deletedSemesterDialog(context, (String deletedSemester) {
                      setState(() {
                        semesters.removeAt(index);
                      });
                    });
                  },
                ),
              ],
            );
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addSemesterDialog(context, (String addSemester) {
            setState(() {
              semesters.add(addSemester);
            });
          });
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

addSemesterDialog(BuildContext context, Function(String) addSemester) {
  TextEditingController semesterController = TextEditingController();
  // Create button
  Widget addButton = TextButton(
    child: Text("Add",
        style: TextStyle(
          color: Colors.black,
        )),
    onPressed: () {
      String semester = semesterController.text;
      // Add the item to the list
      addSemester(semester);
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(
      "Add Semester",
      style: TextStyle(color: Color.fromRGBO(58, 150, 255, 1)),
    ),
    content: Container(
      margin: EdgeInsets.only(left: 20, right: 20),
      padding: EdgeInsets.only(left: 20, right: 20),
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          width: 2,
          color: Color.fromRGBO(162, 158, 158, 1),
        ),
      ),
      alignment: Alignment.center,
      child: TextField(
        controller: semesterController,
        style: TextStyle(
          fontFamily: 'Roboto',
          color: Colors.black54,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        keyboardType: TextInputType.emailAddress,
        cursorColor: Color.fromRGBO(58, 150, 255, 1),
        decoration: InputDecoration(
          hintText: 'Semester',
          hintStyle: TextStyle(
            fontFamily: 'Roboto',
            color: Color.fromRGBO(162, 158, 158, 1),
            fontSize: 18,
          ),
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    ),
    actions: [
      addButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

// deleted semester dialog box

deletedSemesterDialog(BuildContext context, Function(String) deletedSemester) {
  // Create button
  Widget okButton = TextButton(
    child:
        Text("Yes", style: TextStyle(color: Theme.of(context).iconTheme.color)),
    onPressed: () {
      Navigator.of(context).pop();
    },
  );

  // Create AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("⚠ Warning",
        style: TextStyle(color: Color.fromRGBO(58, 150, 255, 1))),
    content: Text("Are You want to deleted This Semester?",
        style: TextStyle(color: Colors.black)),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
