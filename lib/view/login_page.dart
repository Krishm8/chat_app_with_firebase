import 'dart:developer';
import 'package:chat_app_with_firebase/model/user_model.dart';
import 'package:chat_app_with_firebase/utils/auth_helper.dart';
import 'package:chat_app_with_firebase/utils/fcm_helper.dart';
import 'package:chat_app_with_firebase/utils/firestore_helper.dart';
import 'package:chat_app_with_firebase/utils/local_noti_helper.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final GlobalKey<FormState> signUpFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> signInFormKey = GlobalKey<FormState>();

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? email;
  String? password;

  Future<void> requestPermission() async {
    await AndroidFlutterLocalNotificationsPlugin()
        .requestNotificationsPermission();
    await Permission.notification.request();
    await Permission.accessNotificationPolicy.request();
  }

  Future<void> fetchFCMToken() async {
    String? token = await FCMHelper.fcmHelper.getFCMToken();

    log("==================");
    print("$token");
    log("==================");
  }

  Future handleFCMNotificationsInteraction() async {
    // This code only executes if our app state is terminated
    RemoteMessage? remoteMessage =
        await FCMHelper.firebaseMessaging.getInitialMessage();

    if (remoteMessage != null) {
      print("==============");
      print("${remoteMessage.notification!.title}");
      print("${remoteMessage.notification!.body}");
      print("${remoteMessage.data['']}");
      print("==============");
    }

    // This code only executes if our app state is background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage remoteMessage) {
      print("==============");
      print("${remoteMessage.notification!.title}");
      print("${remoteMessage.notification!.body}");
      print("${remoteMessage.data['']}");
      print("==============");
    });
  }

  @override
  void initState() {
    super.initState();
    requestPermission();
    fetchFCMToken();
    handleFCMNotificationsInteraction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Center(
        child: Container(
          height: double.infinity,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue,
                Colors.white,
              ],
              begin: Alignment.topCenter,
            ),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(height: 120,),
                Text(
                  "Get Started",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "Start with singin up or singin.",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w300,
                    color: Colors.black,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Image.network(
                  "https://encrypted-tbn1.gstatic.com/images?q=tbn:ANd9GcRt01zhlwzfaEqLFyHeW-Vxo6UZI33DdL-NYhHjFCZn_4ouBzF-",
                ),
                SizedBox(
                  height: 100,
                ),
                // ElevatedButton(
                //   onPressed: () {
                //     LocalNotificationHelper.localNotificationHelper
                //         .showSimpleNotification(
                //             title: "hello", body: "How are you?");
                //   },
                //   child: Text("simple noti"),
                // ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Sign UP"),
                        content: Form(
                          key: signUpFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: emailController,
                                validator: (val) {
                                  return (val!.isEmpty)
                                      ? "Enter email first"
                                      : null;
                                },
                                onSaved: (val) {
                                  email = val;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter email",
                                  labelText: "Email",
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: passwordController,
                                validator: (val) {
                                  return (val!.isEmpty)
                                      ? "Enter password first"
                                      : null;
                                },
                                onSaved: (val) {
                                  password = val;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter password",
                                  labelText: "Password",
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          OutlinedButton(
                            child: Text("Cancel",style: TextStyle(color: Colors.black,),),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          OutlinedButton(
                            child: Text("Sign Up"),
                            onPressed: () async {
                              if (signUpFormKey.currentState!.validate()) {
                                signUpFormKey.currentState!.save();
            
                                Map<String, dynamic> res = await AuthHelper
                                    .authHelper
                                    .signUp(email: email!, password: password!);
            
                                if (res["user"] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("User Sign Up Successfully..."),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
            
                                  User user = res["user"];
            
                                  UserModel userModel = UserModel(
                                      email: user.email!,
                                      auth_uid: user.uid,
                                      created_at: DateTime.now());
            
                                  // call the insertUser()
                                  await FirestoreHelper.firestoreHelper
                                      .insertUser(userModel: userModel);
                                } else if (res["error"] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res["error"]),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("User Sign Up failed..."),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
            
                                emailController.clear();
                                passwordController.clear();
            
                                email = null;
                                password = null;
            
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.shade100,
                      border: Border.all(),
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Sign Up",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () {
                    showDialog(
                      context: scaffoldKey.currentContext!,
                      builder: (context) => AlertDialog(
                        title: Text("Sign In"),
                        content: Form(
                          key: signInFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: emailController,
                                validator: (val) {
                                  return (val!.isEmpty)
                                      ? "Enter email first"
                                      : null;
                                },
                                onSaved: (val) {
                                  email = val;
                                },
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter email",
                                  labelText: "Email",
                                ),
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: 12),
                              TextFormField(
                                controller: passwordController,
                                validator: (val) {
                                  return (val!.isEmpty)
                                      ? "Enter password first"
                                      : null;
                                },
                                onSaved: (val) {
                                  password = val;
                                },
                                obscureText: true,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: "Enter password",
                                  labelText: "Password",
                                ),
                                keyboardType: TextInputType.text,
                                textInputAction: TextInputAction.done,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          OutlinedButton(
                            child: Text("Cancel",style: TextStyle(color: Colors.black),),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          OutlinedButton(
                            child: Text("Sign In"),
                            onPressed: () async {
                              if (signInFormKey.currentState!.validate()) {
                                signInFormKey.currentState!.save();
            
                                Map<String, dynamic> res = await AuthHelper
                                    .authHelper
                                    .signIn(email: email!, password: password!);
            
                                // Navigator.pop(context);
            
                                if (res["user"] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text("User Sign In Successfully..."),
                                      backgroundColor: Colors.green,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
            
                                  User user = res["user"];
            
                                  UserModel userModel = UserModel(
                                    email: user.email!,
                                    auth_uid: user.uid,
                                    created_at: DateTime.now(),
                                  );
            
                                  // call the insertUser()
                                  await FirestoreHelper.firestoreHelper
                                      .insertUser(userModel: userModel);
            
                                  // push a user to home_page
                                  Navigator.pushReplacementNamed(context, '/',
                                      arguments: res["user"]);
                                } else if (res["error"] != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(res["error"]),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("User Sign In failed..."),
                                      backgroundColor: Colors.redAccent,
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
            
                                emailController.clear();
                                passwordController.clear();
            
                                email = null;
                                password = null;
                              }
                            },
                          ),
                        ],
                      ),
                    );
                  },
                  child: Container(
                    height: 50,
                    width: 300,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.all(
                        Radius.circular(30),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        "Sign In",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 280,
                  child: Divider(
                    height: 2,
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                InkWell(
                  onTap: () async {
                    Map<String, dynamic> res =
                        await AuthHelper.authHelper.signInWithAnonymously();
            
                    if (res["user"] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("User Sign In Successfully..."),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      // push a user to home_page
                      Navigator.of(context)
                          .pushReplacementNamed('/', arguments: res["user"]);
                    } else if (res["error"] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(res["error"]),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("User Sign In failed..."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        "Anonymously Login",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    print("i m in presssed");
                    Map<String, dynamic> res =
                        await AuthHelper.authHelper.signInWithGoogle();
            
                    if (res["user"] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("User Sign In Successfully..."),
                          backgroundColor: Colors.green,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
            
                      User user = res["user"];
            
                      UserModel userModel = UserModel(
                        email: user.email!,
                        auth_uid: user.uid,
                        created_at: DateTime.now(),
                        logged_in_at: DateTime.now(),
                      );
            
                      // call the insertUser()
                      await FirestoreHelper.firestoreHelper
                          .insertUser(userModel: userModel);
                      print("i m in if\n");
                      print("i m in if\n");
                      print("i m in if");
                      // push a user to home_page
                      Navigator.of(context)
                          .pushReplacementNamed('/', arguments: res["user"]);
                    } else if (res["error"] != null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("${res["error"]}"),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      print("i m in else if\n");
                      print("i m in else if\n");
                      print("i m in else if\n");
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("User Sign In failed..."),
                          backgroundColor: Colors.redAccent,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      print("i m in else\n");
                      print("i m in else\n");
                      print("i m in else");
                    }
                  },
                  child: Container(
                    height: 50,
                    width: 200,
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        "Sign In with Google",
                        style: TextStyle(
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  //
  // validateAndSignUp() {
  //   showDialog(
  //     context: context,
  //     builder: (context) => AlertDialog(
  //       title: Text("Sign UP"),
  //       content: Form(
  //         key: signUpFormKey,
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextFormField(
  //               controller: emailController,
  //               validator: (val) {
  //                 return (val!.isEmpty) ? "Enter email first" : null;
  //               },
  //               onSaved: (val) {
  //                 email = val;
  //               },
  //               decoration: InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: "Enter email",
  //                 labelText: "Email",
  //               ),
  //               keyboardType: TextInputType.emailAddress,
  //               textInputAction: TextInputAction.next,
  //             ),
  //             const SizedBox(height: 12),
  //             TextFormField(
  //               controller: passwordController,
  //               validator: (val) {
  //                 return (val!.isEmpty) ? "Enter password first" : null;
  //               },
  //               onSaved: (val) {
  //                 password = val;
  //               },
  //               obscureText: true,
  //               decoration: InputDecoration(
  //                 border: OutlineInputBorder(),
  //                 hintText: "Enter password",
  //                 labelText: "Password",
  //               ),
  //               keyboardType: TextInputType.text,
  //               textInputAction: TextInputAction.done,
  //             ),
  //           ],
  //         ),
  //       ),
  //       actions: [
  //         OutlinedButton(
  //           child: Text("Cancel"),
  //           onPressed: () {
  //             Navigator.pop(context);
  //           },
  //         ),
  //         OutlinedButton(
  //           child: Text("Sign Up"),
  //           onPressed: () async {
  //             if (signUpFormKey.currentState!.validate()) {
  //               signUpFormKey.currentState!.save();
  //
  //               Map<String, dynamic> res = await AuthHelper.authHelper
  //                   .signUp(email: email!, password: password!);
  //
  //               if (res["user"] != null) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text("User Sign Up Successfully..."),
  //                     backgroundColor: Colors.green,
  //                     behavior: SnackBarBehavior.floating,
  //                   ),
  //                 );
  //
  //                 User user = res["user"];
  //
  //                 UserModel userModel = UserModel(
  //                     email: user.email!,
  //                     auth_uid: user.uid,
  //                     created_at: DateTime.now());
  //
  //                 // call the insertUser()
  //                 await FirestoreHelper.firestoreHelper
  //                     .insertUser(userModel: userModel);
  //               } else if (res["error"] != null) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text(res["error"]),
  //                     backgroundColor: Colors.redAccent,
  //                     behavior: SnackBarBehavior.floating,
  //                   ),
  //                 );
  //               } else {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   SnackBar(
  //                     content: Text("User Sign Up failed..."),
  //                     backgroundColor: Colors.redAccent,
  //                     behavior: SnackBarBehavior.floating,
  //                   ),
  //                 );
  //               }
  //
  //               emailController.clear();
  //               passwordController.clear();
  //
  //               email = null;
  //               password = null;
  //
  //               Navigator.pop(context);
  //             }
  //           },
  //         ),
  //       ],
  //     ),
  //   );
  // }

  validateAndSignIn() {
    // showDialog(
    //   context: scaffoldKey.currentContext!,
    //   builder: (context) => AlertDialog(
    //     title: Text("Sign In"),
    //     content: Form(
    //       key: signInFormKey,
    //       child: Column(
    //         mainAxisSize: MainAxisSize.min,
    //         children: [
    //           TextFormField(
    //             controller: emailController,
    //             validator: (val) {
    //               return (val!.isEmpty) ? "Enter email first" : null;
    //             },
    //             onSaved: (val) {
    //               email = val;
    //             },
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Enter email",
    //               labelText: "Email",
    //             ),
    //             keyboardType: TextInputType.emailAddress,
    //             textInputAction: TextInputAction.next,
    //           ),
    //           const SizedBox(height: 12),
    //           TextFormField(
    //             controller: passwordController,
    //             validator: (val) {
    //               return (val!.isEmpty) ? "Enter password first" : null;
    //             },
    //             onSaved: (val) {
    //               password = val;
    //             },
    //             obscureText: true,
    //             decoration: InputDecoration(
    //               border: OutlineInputBorder(),
    //               hintText: "Enter password",
    //               labelText: "Password",
    //             ),
    //             keyboardType: TextInputType.text,
    //             textInputAction: TextInputAction.done,
    //           ),
    //         ],
    //       ),
    //     ),
    //     actions: [
    //       OutlinedButton(
    //         child: Text("Cancel"),
    //         onPressed: () {
    //           Navigator.pop(context);
    //         },
    //       ),
    //       OutlinedButton(
    //         child: Text("Sign In"),
    //         onPressed: () async {
    //           if (signInFormKey.currentState!.validate()) {
    //             signInFormKey.currentState!.save();
    //
    //             Map<String, dynamic> res = await AuthHelper.authHelper
    //                 .signIn(email: email!, password: password!);
    //
    //             // Navigator.pop(context);
    //
    //             if (res["user"] != null) {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text("User Sign In Successfully..."),
    //                   backgroundColor: Colors.green,
    //                   behavior: SnackBarBehavior.floating,
    //                 ),
    //               );
    //
    //               User user = res["user"];
    //
    //               UserModel userModel = UserModel(
    //                 email: user.email!,
    //                 auth_uid: user.uid,
    //                 created_at: DateTime.now(),
    //               );
    //
    //               // call the insertUser()
    //               await FirestoreHelper.firestoreHelper
    //                   .insertUser(userModel: userModel);
    //
    //               // push a user to home_page
    //               Navigator.pushReplacementNamed(context, '/',
    //                   arguments: res["user"]);
    //             } else if (res["error"] != null) {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text(res["error"]),
    //                   backgroundColor: Colors.redAccent,
    //                   behavior: SnackBarBehavior.floating,
    //                 ),
    //               );
    //             } else {
    //               ScaffoldMessenger.of(context).showSnackBar(
    //                 SnackBar(
    //                   content: Text("User Sign In failed..."),
    //                   backgroundColor: Colors.redAccent,
    //                   behavior: SnackBarBehavior.floating,
    //                 ),
    //               );
    //             }
    //
    //             emailController.clear();
    //             passwordController.clear();
    //
    //             email = null;
    //             password = null;
    //           }
    //         },
    //       ),
    //     ],
    //   ),
    // );
  }
}
