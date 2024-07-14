import 'dart:ui';
import 'package:admin_panel/firebase_options.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/loginScreen.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/shared_preferences_manager.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/signUpScreen.dart';
import 'package:admin_panel/presentation/appStartupAuthorisation/splashScreen.dart';
import 'package:admin_panel/session_listner.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferencesManager.clearSharedPreferencesIfNeeded();
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  //   return true;
  // };
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  MyApp({Key? key}) : super(key: key);
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  Future<void> navigateToLogin() async {
    print(
        'The Auto logout timer has elapsed , auto logout triggred, going to login screen');

    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    MyApp.navigatorKey.currentState!.pushReplacement(
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SessionTimeOutListener(
      duration: const Duration(minutes: 60),
      onTimeOut: navigateToLogin,
      child: MaterialApp(
        navigatorKey: MyApp.navigatorKey,
        debugShowCheckedModeBanner: false,
        title: 'PKD Admin Panel Web',
        theme: ThemeData(
          useMaterial3: false,
          appBarTheme: const AppBarTheme(
            color: Colors.amber,
            iconTheme: IconThemeData(color: Colors.black),
          ),
        ),
        home: SplashScreen(),
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));
  }
}
