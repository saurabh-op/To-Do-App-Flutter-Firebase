import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gap/gap.dart';
import 'package:todoapp/UI%20components/my_button.dart';
import 'package:todoapp/UI%20components/my_text_field.dart';
import 'package:todoapp/pages/home.dart';
import 'package:todoapp/pages/login.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => SignUpState();
}

class SignUpState extends State<SignUp> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController ConfirmPasswordController = TextEditingController();
  TextEditingController EmailController = TextEditingController();

  bool showPass = false;
  bool showConfirm = false;
  showConfPass() {
    setState(() {
      showConfirm = !showConfirm;
    });
  }

  showPassword() {
    setState(() {
      showPass = !showPass;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Gap(100),
              Text(
                'Sign Up',
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
              const SizedBox(height: 30),
              TextFormField(
                controller: ConfirmPasswordController,
                decoration: const InputDecoration(
                  labelText: 'Confirm Password',
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
              Gap(10),
              MyButton(
                customColor: const Color.fromARGB(255, 10, 185, 121),
                text: "Sign up",
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
                  else if (ConfirmPasswordController.text.isEmpty)
                    Fluttertoast.showToast(
                      msg: "Enter the confirmation password",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                  else if (passwordController.text !=
                      ConfirmPasswordController.text)
                    Fluttertoast.showToast(
                      msg: "Password not match",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      backgroundColor: Colors.black,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                  else {
                    try {
                      UserCredential userCredential = await FirebaseAuth
                          .instance
                          .createUserWithEmailAndPassword(
                              email: EmailController.text,
                              password: passwordController.text);

                      if (userCredential != null) {
                        Fluttertoast.showToast(
                          msg: "Success !",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      }
                    } on FirebaseAuthException catch (e) {
                      if (e.code == 'weak-password') {
                        Fluttertoast.showToast(
                          msg: "Weak password !",
                          toastLength: Toast.LENGTH_SHORT,
                          gravity: ToastGravity.BOTTOM,
                          backgroundColor: Colors.black,
                          textColor: Colors.white,
                          fontSize: 14.0,
                        );
                      } else if (e.code == 'email-already-in-use') {
                        Fluttertoast.showToast(
                          msg: "Existing account found with this email",
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
                  }
                },
              ),
              const SizedBox(height: 20),
              const Text(
                "Or sign up with",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 20),
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
                  const SizedBox(width: 20),
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
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Already have an account ?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: const Text(
                      "LOG IN",
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
    );
  }
}
