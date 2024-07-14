import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/pages/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference root = FirebaseDatabase.instance.ref();
  TextEditingController taskController = TextEditingController();
  String id = '';

  @override
  void initState() {
    super.initState();
    getidpass();
  }

  void getidpass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String user = await pref.getString('userID')!;

    setState(() {
      id = user;
    });
  }

  void clearLocalStorage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (contex) => LoginPage()));
  }

  Future<void> saveTask(BuildContext context, String userId) async {
    // Create a reference to the tasks node for the current user
    print('saving task for... $userId');
    DatabaseReference tasklist =
        FirebaseDatabase.instance.ref('users/$userId/tasks');

    String taskId = tasklist.push().key!;

    // Set the task data at the generated key within the tasks node
    tasklist.child(taskId).set(taskController.text).then((_) {
      Fluttertoast.showToast(
        msg: "Task added",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      setState(() {
        taskController.clear();
      });

      Navigator.of(context).pop();
    }).catchError((e) {
      print(e);
    });
  }

  void addNewTAskDialouge(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('New Task'),
          content: TextField(
            controller: taskController,
            style: TextStyle(fontSize: 20),
            maxLines: 3,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.isEmpty)
                  Fluttertoast.showToast(
                    msg: "Task can't be empty",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                else
                  saveTask(context, userId);
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

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
      ElevatedButton(
        onPressed: () {
          clearLocalStorage();
        },
        style: ElevatedButton.styleFrom(
            shape: CircleBorder(),
            padding: EdgeInsets.all(8),
            backgroundColor: Colors.black),
        child: Icon(
          Icons.delete,
          size: 40,
          color: Colors.white,
        ),
      ),
      Gap(5),
    ]));
  }
}
