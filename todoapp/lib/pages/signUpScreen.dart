// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui';
import 'package:admin_panel/presentation/addproducts/editImages.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/verificationScreen.dart';
import 'package:admin_panel/services/tokenId.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignUpScreen extends StatefulWidget {
  final String phoneNumber;
  const SignUpScreen({Key? key, required this.phoneNumber}) : super(key: key);

  @override
  _AdminRegistrationPageState createState() => _AdminRegistrationPageState();
}

class _AdminRegistrationPageState extends State<SignUpScreen> {
  List<Uint8List>? localImage = [];
  final ImagePicker imagePicker = ImagePicker();

  TextEditingController firstNameController = TextEditingController();
  TextEditingController EmailController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();

  void expandImage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: Colors.white,
            body: Stack(
              children: [
                Positioned.fill(
                  child: GestureDetector(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 80, bottom: 8, left: 8, right: 8),
                        child: PhotoView(
                          imageProvider: MemoryImage(localImage![0]),
                          backgroundDecoration:
                              const BoxDecoration(color: Colors.white),
                          minScale: PhotoViewComputedScale.contained,
                          maxScale: PhotoViewComputedScale.covered * 2,
                        ),
                      )),
                ),
                Positioned(
                  top: 40,
                  left: 20,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                    },
                    child: const Icon(
                      Icons.close,
                      color: Colors.black,
                      size: 30,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void selectMainImage() async {
    final XFile? pickedImage =
        await imagePicker.pickImage(source: ImageSource.gallery);
    List<XFile> pickedImageList = [];
    if (pickedImage != null) {
      final List<XFile> editedImages = await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditImages([pickedImage]),
        ),
      );
      pickedImageList.add(editedImages[0]);
      localImage = List.generate(pickedImageList.length, (_) => Uint8List(0));
      var bytes = await pickedImageList[0].readAsBytes();
      localImage![0] = bytes;
      print('${localImage!.length}');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Images Selected'),
        ),
      );
    }

    setState(() {});
  }

  Future<void> postPersonalDetails() async {
    String token = '';
    Map<String, String> updatedFields = {
      "firstName": firstNameController.text,
      "lastName": lastNameController.text,
      "email": EmailController.text,
      "phone": widget.phoneNumber,
      "admin": "true",
    };
    var apiurl = /*flag*/ "https://api.pehchankidukan.com/admin/signUpNewUser";
    var uri = Uri.parse(apiurl);
    try {
      var request = http.MultipartRequest('POST', uri);

      Uint8List imageData = localImage![0];
      request.files.add(http.MultipartFile(
        'images',
        http.ByteStream.fromBytes(imageData),
        imageData.length,
        filename: 'image_.jpg',
        contentType: MediaType('image', 'jpeg'),
      ));

      request.fields.addAll(updatedFields);

      final streamedResponse = await request.send();

      final response = await http.Response.fromStream(streamedResponse);

      final Map<String, dynamic> responseData = json.decode(response.body);
      if (response.statusCode == 201) {
        token = responseData['token'];
        TokenId.token = token;
        TokenId.id = "";
        TokenId.phone = widget.phoneNumber;
        TokenId.isVerified = false;

        var pref = await SharedPreferences.getInstance();
        pref.setString(StorageService.keyToken, token);
        pref.setBool(StorageService.keyVerified, false);
        pref.setString(StorageService.keyPhoneNumber, widget.phoneNumber);

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => VerificationScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(responseData['message']),
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Colors.amberAccent.shade400,
        title: const Text(
          'Basic Details',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const Gap(30),
            Text(
              'Almost there !',
              style: TextStyle(
                  color: Colors.blueGrey[700],
                  fontSize: 30,
                  fontWeight: FontWeight.bold),
            ),
            const Gap(20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(children: [
                  InkWell(
                      child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color.fromARGB(255, 255, 255, 255),
                            border: Border.all(
                              color: Colors.black,
                              width: 3,
                            ),
                          ),
                          child: ClipOval(
                              child: localImage!.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundColor:
                                          const Color.fromARGB(91, 103, 96, 96),
                                      radius: 60,
                                      backgroundImage:
                                          MemoryImage(localImage![0]))
                                  : const CircleAvatar(
                                      backgroundColor:
                                          Color.fromARGB(91, 103, 96, 96),
                                      radius: 60,
                                      backgroundImage: AssetImage(
                                          'assets/images/addProfileImage.png'),
                                    ))),
                      onTap: () async {
                        localImage!.isNotEmpty
                            ? expandImage(context)
                            : selectMainImage();
                      }),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: localImage!.isNotEmpty
                        ? Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(
                                color: Colors.black,
                                width: 0.5,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.delete,
                                size: 35,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                setState(() {
                                  setState(() {
                                    localImage!.clear();
                                  });
                                });
                              },
                            ),
                          )
                        : Container(),
                  ),
                ])
              ],
            ),
            const Gap(20),
            Container(
              width: 340,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(20),
                color: const Color.fromARGB(255, 255, 255, 255),
                border: Border.all(
                  color: Colors.black,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    const Gap(15),
                    TextFormField(
                      controller: firstNameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 2) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const Gap(15),
                    TextFormField(
                      controller: lastNameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 2) {
                          return 'Please enter your Last Name';
                        }
                        return null;
                      },
                    ),
                    const Gap(15),
                    TextFormField(
                      controller: EmailController,
                      decoration: const InputDecoration(
                        labelText: 'Email *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: Icon(
                          Icons.email_outlined,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 2) {
                          return 'Please enter your Last Name';
                        }
                        return null;
                      },
                    ),
                    const Gap(15),
                    TextFormField(
                      initialValue: widget.phoneNumber,
                      enabled: false,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Mobile No. *',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.black,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                      validator: (value) {
                        if (value!.isEmpty || value.length < 2) {
                          return 'Please enter Mobile No.';
                        }
                        return null;
                      },
                    ),
                    const Gap(20),
                    ElevatedButton(
                      style: ButtonStyle(
                        elevation: MaterialStateProperty.all<double>(2),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.blue),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (firstNameController.text.isNotEmpty &&
                            lastNameController.text.isNotEmpty &&
                            EmailController.text.isNotEmpty &&
                            localImage!.isNotEmpty) {
                          // ScaffoldMessenger.of(context)
                          //     .showSnackBar(const SnackBar(
                          //   content: Text('All good'),
                          // ));
                          postPersonalDetails();
                        } else {
                          if (firstNameController.text.isEmpty ||
                              lastNameController.text.isEmpty ||
                              EmailController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please fill in all fields.'),
                              ),
                            );
                          } else if (localImage!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Rquired profile image'),
                              ),
                            );
                          }
                        }
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Next',
                              style: TextStyle(
                                fontSize: 18,
                                color: Color.fromARGB(255, 255, 255, 255),
                              )),
                          Gap(10),
                          Icon(Icons.arrow_forward, size: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
