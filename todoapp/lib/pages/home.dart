import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/models/taskListModel.dart';
import 'package:todoapp/pages/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  bool loading = false;
  FirebaseDatabase database = FirebaseDatabase.instance;
  DatabaseReference root = FirebaseDatabase.instance.ref();
  TextEditingController taskController = TextEditingController();
  ScrollController scrollController = ScrollController();
  String id = '';

  List<Task> tasksList = [];

  @override
  void initState() {
    super.initState();
    loading = true;
    getidpass();

    handleScrolling();
  }

  void getidpass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String user = await pref.getString('userID')!;

    setState(() {
      id = user;
    });
    getTaskListFromDB();
  }

  void handleScrolling() {
    scrollController.addListener(
      () async {
        if (scrollController.position.maxScrollExtent ==
            scrollController.position.pixels) {
          getTaskListFromDB();
        }
      },
    );
  }

  Future<void> getTaskListFromDB() async {
    print('getting tasks.... for $id');

    final database = FirebaseDatabase.instance;
    final tasksRef = database.ref('users/$id/tasks');
    final snapshot = await tasksRef.get();

    if (snapshot.exists) {
      print('Snapshot value: ${snapshot.value}');

      // Ensure snapshot.value is cast to a Map
      final tasksMap = Map<String, dynamic>.from(snapshot.value as Map);

      tasksMap.forEach((taskId, taskDetail) {
        if (taskId != 'taskid') {
          tasksList.add(Task.fromJson(taskDetail, taskId));
        }
      });
    } else {
      print('No tasks found.');
    }
    setState(() {
      loading = false;
    });
  }

  void clearLocalStorage() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.clear();
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (contex) => LoginPage()));
  }

  Future<void> saveTask(BuildContext context, String userId) async {
    print('saving task for... $userId');
    DatabaseReference tasklist =
        FirebaseDatabase.instance.ref('users/$userId/tasks');

    String taskId = tasklist.push().key!;
    String taskdetail = taskController.text;

    tasklist.child(taskId).set(taskdetail).then((_) {
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

  Future<String?> updateTask(String taskId, String updatedTaskDetails) async {
    bool updatingTask = false;
    String? result;
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Update Task'),
          content: TextField(
            controller: taskController,
            style: TextStyle(fontSize: 20),
            maxLines: 3,
            autofocus: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  taskController.clear();
                });
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (taskController.text.isEmpty)
                  Fluttertoast.showToast(
                    msg: "Task can't be empty",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                else {
                  setState(() {
                    updatingTask = true;
                  });
                  DatabaseReference taskRef =
                      FirebaseDatabase.instance.ref('users/$id/tasks');

                  await taskRef.update({
                    "$taskId": "${taskController.text}",
                  }).then((_) {
                    Fluttertoast.showToast(
                      msg: "Updated",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black,
                      textColor: Colors.green,
                      fontSize: 14.0,
                    );

                    setState(() {
                      result = taskController.text;
                      taskController.clear();
                      updatingTask = false;
                    });

                    Navigator.pop(context);
                  }).catchError((error) {
                    Fluttertoast.showToast(
                      msg: "Error updating",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black,
                      textColor: Colors.red,
                      fontSize: 14.0,
                    );
                  });
                  setState(() {
                    updatingTask = false;
                  });
                }
              },
              child: Text('Update'),
            ),
          ],
        );
      },
    );

    if (result != null) {
      return result;
    }
  }

  Future<void> deleteThisTask(String taskId, int index) async {
    DatabaseReference taskRef =
        FirebaseDatabase.instance.ref('users/$id/tasks/$taskId');

    await taskRef.remove().then((_) {
      Fluttertoast.showToast(
        msg: "Task deleted",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      setState(() {
        tasksList.removeAt(index);
      });
    }).catchError((error) {
      Fluttertoast.showToast(
        msg: "Error deleting task",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.red,
        fontSize: 14.0,
      );
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
                setState(() {
                  taskController.clear();
                });
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
        resizeToAvoidBottomInset: false,
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          FloatingActionButton(
            onPressed: () {
              if (!loading)
                setState(() {
                  tasksList.clear();
                  getTaskListFromDB();
                });
            },
            backgroundColor: Colors.black,
            child: Icon(
              Icons.refresh,
              size: 40,
              color: Colors.white,
            ),
          ),
          Gap(10),
          FloatingActionButton(
            onPressed: () {
              addNewTAskDialouge(context, id);
            },
            backgroundColor: Colors.black,
            child: Icon(
              Icons.add,
              size: 40,
              color: Colors.white,
            ),
          ),
        ]),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Gap(8),
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                ),
                child: IconButton(
                    icon: Icon(
                      Icons.person,
                      size: 20,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Logout'),
                            content: Text('Are you sure you want to logout?'),
                            actions: <Widget>[
                              TextButton(
                                child: Text('Logout'),
                                onPressed: () {
                                  clearLocalStorage();
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: Text('Cancel'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }),
              )
            ],
          ),
        ),
        body: Column(mainAxisSize: MainAxisSize.min, children: [
          Gap(8),
          loading
              ? CircularProgressIndicator()
              : SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  controller: scrollController,
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ListView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding:
                            const EdgeInsets.only(left: 10, right: 10, top: 10),
                        itemCount: tasksList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Card(
                            color: Colors.white,
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 10, right: 10, top: 10, bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Flexible(
                                    child: Text(
                                      softWrap: true,
                                      tasksList[index].taskDetail,
                                      style: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                    ),
                                  ),
                                  Gap(5),
                                  Row(
                                    children: [
                                      IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            taskController.text =
                                                tasksList[index].taskDetail;
                                          });
                                          String? finalTask = await updateTask(
                                              tasksList[index].taskId,
                                              tasksList[index].taskDetail);
                                          print('final task : $finalTask');

                                          if (finalTask != null)
                                            setState(() {
                                              tasksList[index] = Task(
                                                taskId: tasksList[index].taskId,
                                                taskDetail: finalTask,
                                              );
                                            });
                                        },
                                        icon: Icon(
                                          Icons.mode_edit_outlined,
                                          color: Colors.green,
                                        ),
                                      ),
                                      Gap(4),
                                      IconButton(
                                        onPressed: () {
                                          deleteThisTask(
                                              tasksList[index].taskId, index);
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      const Gap(100),
                    ],
                  ),
                ),
        ]));
  }
}
