import 'dart:ui';

import 'package:chat_app_with_firebase/utils/auth_helper.dart';
import 'package:chat_app_with_firebase/utils/firestore_helper.dart';
import 'package:chat_app_with_firebase/utils/local_noti_helper.dart';
import 'package:chat_app_with_firebase/view/component/my_drawer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    User? user = ModalRoute.of(context)!.settings.arguments as User?;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent.shade100,
        title: Text("Chats"),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: InkWell(
                    onTap: () {
                      LocalNotificationHelper.localNotificationHelper
                          .showSimpleNotification(
                        title: "Hello",
                        body: "I am Simple Notification",
                      );
                      Navigator.pop(context);
                    },
                    child: Text("Simple Notification"),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    onTap: () {
                      LocalNotificationHelper.localNotificationHelper
                          .showScheduledNotification();
                      Navigator.pop(context);
                    },
                    child: Text("Scheduled Notification"),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    onTap: () {
                      LocalNotificationHelper.localNotificationHelper
                          .showBigPictureNotification();
                      Navigator.pop(context);
                    },
                    child: Text("BigPicture Notification"),
                  ),
                ),
                PopupMenuItem(
                  child: InkWell(
                    onTap: () {
                      LocalNotificationHelper.localNotificationHelper
                          .showMediaStyleNotification();
                      Navigator.pop(context);
                    },
                    child: Text("MediaStyle Notification"),
                  ),
                ),
              ];
            },
          ),
          SizedBox(
            width: 15,
          ),
        ],
      ),
      drawer: MyDrawer(user: user),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blueAccent,
              Colors.white,
            ],
          ),
        ),
        child: StreamBuilder(
          stream: FirestoreHelper.firestoreHelper.fetchAllUsers(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text("ERROR: ${snapshot.error}"),
              );
            } else if (snapshot.hasData) {
              QuerySnapshot<Map<String, dynamic>>? querySnapshot =
                  snapshot.data;

              List<QueryDocumentSnapshot<Map<String, dynamic>>> allDocs =
                  (querySnapshot != null) ? querySnapshot.docs : [];

              return (allDocs.isEmpty)
                  ? Center(
                      child: Text("No any users...."),
                    )
                  : ListView.builder(
                      itemCount: allDocs.length,
                      itemBuilder: (context, i) {
                        Timestamp timestamp = allDocs[i].data()["created_at"];

                        DateTime dateTime = timestamp.toDate();

                        return (allDocs[i].data()["email"] ==
                                AuthHelper.firebaseAuth.currentUser!.email)
                            ? Container()
                            : ListTile(
                                leading: CircleAvatar(
                                  radius: 20,
                                  child: Text(allDocs[i]
                                      .data()["email"][0]
                                      .toString()
                                      .toUpperCase()),
                                ),
                                trailing: Icon(Icons.keyboard_arrow_right),
                                title: Text("${allDocs[i].data()["email"]}"),
                                subtitle: Text(
                                    "${dateTime.day}-${dateTime.month}-${dateTime.year} | ${dateTime.hour}:${dateTime.minute}"),
                                onTap: () async {
                                  // call the logic of creating a chatroom
                                  await FirestoreHelper.firestoreHelper
                                      .createChatroom(
                                          receiver_id:
                                              allDocs[i].data()["auth_uid"]);
                                  Navigator.of(context).pushNamed("chat_page",
                                      arguments: allDocs[i].data()["auth_uid"]);
                                },
                              );
                      },
                    );
            }

            return Center(
              child: CircularProgressIndicator(),
            );
          },
        ),
      ),
    );
  }
}
