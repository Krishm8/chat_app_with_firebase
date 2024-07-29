import 'package:chat_app_with_firebase/view/chat_page.dart';
import 'package:chat_app_with_firebase/view/home_page.dart';
import 'package:chat_app_with_firebase/view/login_page.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );


  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: "/",
      routes: {
        "/": (context) => LoginPage(),
        '/': (context) => HomePage(),
        'chat_page': (context) => ChatPage(),
      },
    ),
  );
}