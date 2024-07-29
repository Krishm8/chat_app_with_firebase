import 'dart:developer';

import 'package:chat_app_with_firebase/utils/auth_helper.dart';
import 'package:chat_app_with_firebase/utils/firestore_helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController chatController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    String receiver_id = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("Chats"),
        centerTitle: true,
      ),
      body: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [
            Colors.blue,
            Colors.white,
          ])
        ),
        child: Column(
          children: [
            Expanded(
              flex: 16,
              child: FutureBuilder(
                future: FirestoreHelper.firestoreHelper
                    .fetchMessages(receiver_id: receiver_id),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text("ERROR: ${snapshot.error}"),
                    );
                  } else {
                    // Data is available
                    return StreamBuilder(
                      stream: snapshot.data,
                      builder: (context, ss) {
                        if (ss.hasError) {
                          return Center(
                            child: Text("ERROR: ${ss.error}"),
                          );
                        } else if (ss.hasData) {
                          List<QueryDocumentSnapshot<Map<String, dynamic>>>
                              allDocs = (ss.data == null) ? [] : ss.data!.docs;

                          return ListView.builder(
                            reverse: true,
                            itemCount: allDocs.length,
                            itemBuilder: (context, i) {
                              // Adjust this part according to your document structure
                              return Row(
                                mainAxisAlignment:
                                    (allDocs[i].data()["sent_by"] ==
                                            AuthHelper
                                                .firebaseAuth.currentUser!.uid)
                                        ? MainAxisAlignment.end
                                        : MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Material(
                                        child: Container(
                                          padding: const EdgeInsets.all(10),
                                          decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border:
                                                Border.all(color: Colors.black),
                                            borderRadius: (allDocs[i]
                                                        .data()["sent_by"] ==
                                                    AuthHelper.firebaseAuth
                                                        .currentUser!.uid)
                                                ? BorderRadius.horizontal(
                                                    left: Radius.circular(20),
                                                    right: Radius.circular(10),
                                                  )
                                                : BorderRadius.horizontal(
                                                    right: Radius.circular(20),
                                                    left: Radius.circular(10),
                                                  ),
                                          ),
                                          child: Text(
                                              "${allDocs[i].data()["msg"]}"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              );
                            },
                          );
                        }
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      },
                    );
                  }
                },
              ),
            ),
            Expanded(
                flex: 2,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: chatController,
                        decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: "Message..."),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () async {
                        await FirestoreHelper.firestoreHelper.sendMessage(
                            receiver_id: receiver_id, msg: chatController.text);

                        chatController.clear();
                      },
                    ),
                  ],
                )),
          ],
        ),
      ),
    );
  }
}
