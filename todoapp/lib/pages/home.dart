import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/models/taskListModel.dart';
import 'package:todoapp/pages/login.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:audioplayers/audioplayers.dart';

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
  List<int> deleteList = [];

  bool activateSingleTapToSelect = false;

  final player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    loading = true;
    getidpass();
  }

  void getidpass() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    String user = await pref.getString('userID')!;

    setState(() {
      id = user;
    });
    getTaskListFromDB();
  }

  Future<void> getTaskListFromDB() async {
    print('hit');
    setState(() {
      loading = true;
    });
    final database = FirebaseDatabase.instance;
    final tasksRef = database.ref('users/$id/tasks');
    final snapshot = await tasksRef.get();

    if (snapshot.exists) {
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
        context, MaterialPageRoute(builder: (contex) => const LoginPage()));
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
        this.tasksList.clear();
        getTaskListFromDB();
        taskController.clear();
      });

      Navigator.of(context).pop();
    }).catchError((e) {
      Fluttertoast.showToast(
        msg: "Error adding task",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.black,
        textColor: Colors.red,
        fontSize: 14.0,
      );
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
          title: const Text('Update Task'),
          content: TextField(
            controller: taskController,
            style: const TextStyle(fontSize: 20),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (taskController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Task can't be empty",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                } else {
                  setState(() {
                    updatingTask = true;
                  });
                  DatabaseReference taskRef =
                      FirebaseDatabase.instance.ref('users/$id/tasks');

                  await taskRef.update({
                    taskId: taskController.text,
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
              child: const Text('Update'),
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

  Future<void> markItCompleted(String taskId, int index) async {
    DatabaseReference taskRef =
        FirebaseDatabase.instance.ref('users/$id/tasks/$taskId');

    await taskRef.remove().then((_) {
      setState(() {
        tasksList[index].isCompleted = true;
      });
      swooshSound();
      Future.delayed(Duration(milliseconds: 900), () {
        setState(() {
          tasksList.removeAt(index);
        });

        Fluttertoast.showToast(
          msg: "Task Completed",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0,
        );
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

  Future<void> deleteMultipleTasks() async {
    for (int index in deleteList) {
      deleteThisTask(tasksList[index].taskId, index);
    }
  }

  void addNewTAskDialouge(BuildContext context, String userId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('New Task'),
          content: TextField(
            controller: taskController,
            style: const TextStyle(fontSize: 20),
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
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                if (taskController.text.isEmpty) {
                  Fluttertoast.showToast(
                    msg: "Task can't be empty",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: Colors.black,
                    textColor: Colors.white,
                    fontSize: 14.0,
                  );
                } else {
                  saveTask(context, userId);
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Widget noTaskYet() {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Add new task...',
              style: GoogleFonts.ubuntu(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(100),
          ],
        ),
      ),
    );
  }

  Future<void> swooshSound() async {
    String audioFilePath = "swoosh.mp3";
    await player.play(AssetSource(audioFilePath));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[50],
        resizeToAvoidBottomInset: false,
        floatingActionButton:
            Column(mainAxisAlignment: MainAxisAlignment.end, children: [
          deleteList.isNotEmpty
              ? FloatingActionButton(
                  onPressed: () async {
                    if (!loading) {
                      await deleteMultipleTasks();
                      deleteList.clear();
                    }
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(
                    Icons.delete,
                    size: 40,
                    color: Colors.white,
                  ),
                )
              : FloatingActionButton(
                  onPressed: () {
                    if (!loading) {
                      setState(() {
                        tasksList.clear();
                        getTaskListFromDB();
                      });
                    }
                  },
                  backgroundColor: Colors.black,
                  child: const Icon(
                    Icons.refresh,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
          const Gap(10),
          FloatingActionButton(
            onPressed: () {
              addNewTAskDialouge(context, id);
            },
            backgroundColor: Colors.black,
            child: const Icon(
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
              const Gap(8),
              Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey,
                      spreadRadius: 0.5,
                      blurRadius: 2,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: IconButton(
                    icon: const Icon(
                      Icons.person,
                      size: 20,
                    ),
                    color: Colors.white,
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Logout'),
                                onPressed: () {
                                  clearLocalStorage();
                                  Navigator.of(context).pop();
                                },
                              ),
                              TextButton(
                                child: const Text('Cancel'),
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
          const Gap(8),
          loading
              ? const Center(child: CircularProgressIndicator())
              : tasksList.isEmpty
                  ? noTaskYet()
                  : Flexible(
                      child: SingleChildScrollView(
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        controller: scrollController,
                        physics: const BouncingScrollPhysics(),
                        child: RefreshIndicator(
                          onRefresh: getTaskListFromDB,
                          child: ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            padding: const EdgeInsets.only(
                                left: 10, right: 10, top: 10),
                            itemCount: tasksList.length + 1,
                            itemBuilder: (BuildContext context, int index) {
                              if (index < tasksList.length) {
                                var item = tasksList[index];
                                return InkWell(
                                  onTap: () {
                                    if (activateSingleTapToSelect) {
                                      if (item.isSelected)
                                        setState(() {
                                          item.isSelected = false;
                                          deleteList.remove(index);
                                          if (deleteList.isEmpty)
                                            activateSingleTapToSelect = false;
                                        });
                                      else
                                        setState(() {
                                          item.isSelected = true;
                                          deleteList.add(index);
                                        });
                                    }
                                  },
                                  onLongPress: () {
                                    if (!activateSingleTapToSelect) {
                                      if (item.isSelected)
                                        setState(() {
                                          item.isSelected = false;
                                          deleteList.remove(index);
                                          if (deleteList.isEmpty)
                                            activateSingleTapToSelect = false;
                                        });
                                      else
                                        setState(() {
                                          item.isSelected = true;
                                          deleteList.add(index);
                                          activateSingleTapToSelect = true;
                                        });
                                    }
                                  },
                                  child: Card(
                                    color: item.isSelected
                                        ? Colors.black
                                        : Colors.white,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 2, bottom: 2),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          IconButton(
                                            onPressed: () async {
                                              await markItCompleted(
                                                  item.taskId, index);
                                            },
                                            icon: Icon(
                                              Icons.check_box_outlined,
                                              color: !item.isCompleted
                                                  ? Colors.grey[300]
                                                  : Colors.black,
                                            ),
                                          ),
                                          Expanded(
                                            child: Text(
                                              softWrap: true,
                                              item.taskDetail,
                                              style: GoogleFonts.manrope(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                decoration: item.isCompleted
                                                    ? TextDecoration.lineThrough
                                                    : TextDecoration.none,
                                                color: item.isSelected
                                                    ? Colors.white
                                                    : Colors.black,
                                              ),
                                            ),
                                          ),
                                          const Gap(5),
                                          if (!item.isCompleted)
                                            IconButton(
                                              onPressed: () async {
                                                setState(() {
                                                  taskController.text =
                                                      tasksList[index]
                                                          .taskDetail;
                                                });
                                                String? finalTask =
                                                    await updateTask(
                                                        tasksList[index].taskId,
                                                        tasksList[index]
                                                            .taskDetail);

                                                if (finalTask != null) {
                                                  setState(() {
                                                    tasksList[index] = Task(
                                                      taskId: tasksList[index]
                                                          .taskId,
                                                      taskDetail: finalTask,
                                                    );
                                                  });
                                                }
                                              },
                                              icon: Icon(
                                                Icons.mode_edit_outlined,
                                                color: item.isSelected
                                                    ? Colors.white
                                                    : Colors.grey,
                                              ),
                                            )
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const Gap(40);
                              }
                            },
                          ),
                        ),
                      ),
                    ),
        ]));
  }
}
