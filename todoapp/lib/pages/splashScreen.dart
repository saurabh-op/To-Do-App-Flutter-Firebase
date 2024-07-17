import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/pages/home.dart';
import 'package:todoapp/pages/login.dart';

class splashScreen extends StatefulWidget {
  @override
  State<splashScreen> createState() => splashScreenState();
}

class splashScreenState extends State<splashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _controller.addStatusListener((status) async {
      if (status == AnimationStatus.completed) {
        await checkForSavedDataLocally();
      }
    });
  }

  Future<void> checkForSavedDataLocally() async {
    print('checking for locally stored data: ');
    SharedPreferences pref = await SharedPreferences.getInstance();
    String? id = pref.getString('userID');
    print('id found : $id');
    if (id != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomePage()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Lottie.asset(
          height: 250,
          width: 250,
          'assets/checkbox.json',
          controller: _controller,
          onLoaded: (composition) {
            _controller.duration = composition.duration;
            _controller.forward();
          },
        ),
      ),
    );
  }
}
