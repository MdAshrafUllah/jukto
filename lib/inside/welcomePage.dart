import 'dart:io';

import 'package:awesome_bottom_bar/awesome_bottom_bar.dart';
import 'package:awesome_bottom_bar/widgets/inspired/inspired.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'homePage.dart';
import 'messagePage.dart';
import 'profilePage.dart';
import 'searchPage.dart';

class welcomePage extends StatefulWidget {
  const welcomePage({super.key});

  @override
  State<welcomePage> createState() => _welcomePageState();
}

class _welcomePageState extends State<welcomePage> {
  int _selectedIndex = 0;
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  static const List<TabItem> items = [
    TabItem(
      icon: FontAwesomeIcons.house,
    ),
    TabItem(
      icon: FontAwesomeIcons.magnifyingGlass,
    ),
    TabItem(
      icon: FontAwesomeIcons.solidComment,
    ),
    TabItem(
      icon: FontAwesomeIcons.solidUser,
    ),
  ];

  final List<Widget> _pages = [
    homePage(),
    searchPerson(),
    messagePage(),
    profilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => _onBackbuttonpressed(context),
      child: Scaffold(
        /* app bar here */
        appBar: AppBar(
          automaticallyImplyLeading: false,
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
                    // FirebaseFirestore.instance
                    //     .collection('users')
                    //     .get()
                    //     .then((QuerySnapshot querySnapshot) {
                    //   querySnapshot.docs.forEach((doc) {
                    //     if (doc["email"] == user?.email) {
                    //       setState(() {
                    //         CurrentPic = doc["profileImage"];
                    //       });
                    //     }
                    //   });
                    // });
                    Scaffold.of(context).openEndDrawer();
                  },
                );
              },
            ),
          ],
        ),
        /* drawer here */
        endDrawer: Drawer(),
        /* body srart here*/
        body: Center(
          child: _pages[_selectedIndex],
        ),
        bottomNavigationBar: Container(
          child: BottomBarInspiredOutside(
            items: items,
            backgroundColor: Color.fromRGBO(58, 150, 255, 1),
            color: Colors.white,
            colorSelected: Colors.white,
            indexSelected: _selectedIndex,
            onTap: (int index) => setState(() {
              _selectedIndex = index;
            }),
            top: -25,
            animated: true,
            itemStyle: ItemStyle.circle,
            chipStyle:
                const ChipStyle(notchSmoothness: NotchSmoothness.softEdge),
          ),
        ),
      ),
    );
  }

  Future<bool> _onBackbuttonpressed(BuildContext context) async {
    bool exitApp = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text("Really ?"),
            content: const Text("Do you want to close the app ?"),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(false);
                },
                child: const Text("No"),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                },
                child: const Text("Yes"),
              ),
            ],
          );
        });
    return exitApp;
  }
}
