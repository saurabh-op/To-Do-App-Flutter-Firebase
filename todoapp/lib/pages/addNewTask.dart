import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

TextEditingController taskController = TextEditingController();
Future<void> saveTask(String id) async {}

void addNewTAskDialouge(BuildContext context, String id) {
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
                saveTask(id);
            },
            child: Text('Save'),
          ),
        ],
      );
    },
  );
}
