import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/pages/addNewTask.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference root = FirebaseDatabase.instance.ref();
  String id = '';
  String pass = '';
  @override
  void initState() {
    super.initState();
    getidpass();
  }

  void getidpass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String user = await pref.getString('id')!;
    String password = await pref.getString('pass')!;
    setState(() {
      id = user;
      pass = password;
    });
  }

  void addNewTask(String task) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Column(mainAxisSize: MainAxisSize.max, children: [
      Gap(20),
      SingleChildScrollView(
          //child: ListView.builder(itemBuilder: itemBuilder),
          child: Center(
        child: Padding(
          padding: const EdgeInsets.all(50.0),
          child: Text('Home'),
        ),
      )),
      Gap(10),
      ElevatedButton(
        onPressed: () {
          // Handle button press
          addNewTAskDialouge(context, id);
          print('add task button pressed');
        },
        style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(8),
            backgroundColor: Colors.black),
        child: Icon(
          Icons.add,
          size: 40,
          color: Colors.white,
        ),
      ),
      Gap(5),
    ]));
  }
}
