import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todoapp/UI%20components/my_button.dart';
import 'package:todoapp/UI%20components/my_text_field.dart';
import 'package:todoapp/pages/home.dart';
import 'package:todoapp/pages/login.dart';
import 'package:todoapp/pages/signup.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController EmailController = TextEditingController();
  bool checkingForLocalCreds = false;
  bool processingLogin = false;
  @override
  void initState() {
    super.initState();
    checkingForLocalCreds = true;
    checkForSavedDataLocally();
  }

  Future<void> checkForSavedDataLocally() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    if (pref.getString('id') != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
    setState(() {
      checkingForLocalCreds = false;
    });
  }

  Future<void> saveCredentialsLocally(String userIdObtainedFromFirebase) async {
    print('saving credentials locaally ');
    print('the new user id : $userIdObtainedFromFirebase');
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('userID', userIdObtainedFromFirebase);
    await pref.setString('pass', passwordController.text);

    Fluttertoast.showToast(
      msg: "Login Successful !",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: Colors.black,
      textColor: Colors.white,
      fontSize: 14.0,
    );

    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  Future<void> signIn() async {
    setState(() {
      processingLogin = true;
    });
    print('signing called ');
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(
              email: EmailController.text, password: passwordController.text);
      if (userCredential.user != null) {
        saveCredentialsLocally(userCredential.user!.uid!);
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        Fluttertoast.showToast(
          msg: "User not found",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      } else if (e.code == 'wrong-password') {
        Fluttertoast.showToast(
          msg: "Wrong Password",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 14.0,
        );
      }
    } catch (e) {
      print(e);
    }
    setState(() {
      processingLogin = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(children: [
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Gap(100),
                Text(
                  'Login',
                  style: TextStyle(
                      fontSize: 40,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: EmailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(
                      Icons.email,
                      color: Colors.black,
                    ),
                  ),
                  // onChanged: (value) {
                  //   setState(() {});
                  // },
                  // validator: (value) {
                  //   if (value!.isEmpty || value.length < 2) {
                  //     return 'Please enter your first name';
                  //   }
                  //   return null;
                  // },
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Password',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(
                      Icons.lock,
                      color: Colors.black,
                    ),
                  ),
                  // onChanged: (value) {
                  //   setState(() {});
                  // },
                  // validator: (value) {
                  //   if (value!.isEmpty || value.length < 2) {
                  //     return 'Please enter your first name';
                  //   }
                  //   return null;
                  // },
                ),
                const SizedBox(height: 12),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Row(
                      //   children: [
                      //     Theme(
                      //       data: ThemeData(
                      //         unselectedWidgetColor: Colors.grey[500],
                      //       ),
                      //       child: Checkbox(
                      //         checkColor: Colors.white,
                      //         value: checkTheBox ? true : false,
                      //         onChanged: (value) {
                      //           check();
                      //         },
                      //       ),
                      //     ),
                      //     Text(
                      //       "Remember me",
                      //       style: TextStyle(
                      //         color: Colors.white,
                      //       ),
                      //     )
                      //   ],
                      // ),
                      //                    ----------------------------TODO--------------------------
                      // Text(
                      //   "Forgot password?",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.bold,
                      //     color: Colors.cyan,
                      //   ),
                      // ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                MyButton(
                  customColor: Color.fromARGB(255, 10, 185, 121),
                  text: "Sign in",
                  onTap: () async {
                    if (EmailController.text.isEmpty)
                      Fluttertoast.showToast(
                        msg: "Enter the email",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    else if (passwordController.text.isEmpty)
                      Fluttertoast.showToast(
                        msg: "Enter the password",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.black,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                    else
                      signIn();
                  },
                ),
                const SizedBox(height: 20),
                MyButton(
                    customColor: Colors.grey.shade200,
                    text: "--or-- Dummy Login",
                    onTap: () {
                      setState(() {
                        EmailController.text = 'dummylogin@gmail.com';
                        passwordController.text = 'dummylogin@123';
                        signIn();
                      });
                    }),
                const SizedBox(height: 20),
                Text(
                  "Or sign in with",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      child: Image.asset("assets/facebook.png", width: 50),
                    ),
                    SizedBox(width: 20),
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey.shade700),
                      ),
                      child: Image.asset("assets/google.png", width: 50),
                    ),
                  ],
                ),
                SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account ?",
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 20),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => SignUp()));
                      },
                      child: Text(
                        "REGISTER",
                        style: TextStyle(
                          color: Color.fromARGB(255, 10, 185, 121),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
        if (checkingForLocalCreds || processingLogin)
          Container(
            height: double.infinity,
            width: double.infinity,
            color: Colors.transparent,
            child: Center(
              child: Container(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: Colors.black,
                  ),
                ),
                color: Colors.grey[200],
              ),
            ),
          ),
      ]),
    );
  }
}
