import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:intl/intl.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key, required this.roomId, required this.otherUser}) : super(key: key);

  late String? roomId;
  final String? otherUser;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  final List<Message> messages = [];

  final _textController = TextEditingController();

  @override
  void dispose() {
    scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Stream<QuerySnapshot> getMessagesStream() {
    final firestore = FirebaseFirestore.instance;
    return firestore.collection('Rooms').doc(widget.roomId).collection('messages').orderBy('datetime').snapshots();
  }

  Stream<QuerySnapshot> getName() {
    final firestore = FirebaseFirestore.instance;
    return firestore.collection('Users').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    // 1
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder(
                stream: getName(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    if (snapshot.data!.docs.isNotEmpty) {
                      List<QueryDocumentSnapshot?> allData = snapshot.data!.docs;
                      QueryDocumentSnapshot? data = allData.isNotEmpty ? allData.first : null;
                      if (data != null) {
                        if (data['id'] == widget.otherUser) {
                          return Text(
                            data['name'],
                            style: TextStyle(fontSize: 20),
                          );
                        } else {
                          return Container();
                        }
                      } else {
                        return Container();
                      }
                    } else {
                      return Center(
                        child: Text('No name found'),
                      );
                    }
                  } else {
                    return Center(
                      child: CircularProgressIndicator(color: Colors.blue),
                    );
                  }
                }),
            SizedBox(
              width: 16,
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      backgroundColor: Color(0xFF4622fe),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 1 / 6 - 78),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 9 / 12 - 48,
                    child: StreamBuilder(
                        stream: getMessagesStream(),
                        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                          if (snapshot.hasData) {
                            if (snapshot.data!.docs.isNotEmpty) {
                              List<QueryDocumentSnapshot?> allData = snapshot.data!.docs;
                              messages.clear();
                              QueryDocumentSnapshot? data = allData.isNotEmpty ? allData.first : null;
                              if (data != null) {
                                // setState(() {
                                //   roomId = data.id;
                                // });
                                for (int i = 0; i < allData.length; i++) {
                                  DateTime dateTime = allData[i]!['datetime'].toDate();
                                  String formattedTime = DateFormat.Hm().format(dateTime);
                                  messages.add(
                                    Message(
                                      text: allData[i]!['message'],
                                      mine: allData[i]!['sent_by'] == FirebaseAuth.instance.currentUser!.uid,
                                      time: formattedTime,
                                    ),
                                  );
                                }
                                messages.sort((a, b) => a.time.compareTo(b.time));
                              }
                              return data == null
                                  ? Container()
                                  : ListView.separated(
                                      itemCount: allData.length,
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemBuilder: (BuildContext context, int index) {
                                        return Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            if (index == 0 || messages[index].time != messages[index - 1].time)
                                              Row(
                                                children: [
                                                  SizedBox(
                                                    width: MediaQuery.of(context).size.width / 5,
                                                  ),
                                                  Text(
                                                    messages[index].time,
                                                    style: TextStyle(fontSize: 15),
                                                  ),
                                                ],
                                              ),
                                            if (messages[index].mine == false)
                                              Row(
                                                children: [
                                                  if ((index + 1) == messages.length || messages[index + 1].mine != false)
                                                    Container(
                                                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                                                        height: MediaQuery.of(context).size.width * 1 / 8,
                                                        width: MediaQuery.of(context).size.width * 1 / 8),
                                                  SizedBox(width: ((index + 1) == messages.length || messages[index + 1].mine != false) ? 24 : 72),
                                                  Flexible(
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding: EdgeInsets.all(24),
                                                      decoration: BoxDecoration(
                                                        color: Colors.grey.shade300,
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Text(messages[index].text),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if (messages[index].mine == true)
                                              Row(
                                                children: [
                                                  SizedBox(width: 72),
                                                  Flexible(
                                                    child: Container(
                                                      width: double.infinity,
                                                      padding: EdgeInsets.all(24),
                                                      decoration: BoxDecoration(
                                                        color: Color(0xFF4622fe),
                                                        borderRadius: BorderRadius.circular(16),
                                                      ),
                                                      child: Text(
                                                        messages[index].text,
                                                        style: TextStyle(color: Colors.white),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            if ((index + 1) == messages.length || messages[index].mine != messages[index + 1].mine)
                                              SizedBox(
                                                height: 24,
                                              )
                                          ],
                                        );
                                      },
                                      separatorBuilder: (BuildContext context, int index) {
                                        return const SizedBox(height: 8);
                                      },
                                    );
                            } else {
                              return Center(
                                child: Text('No conversation found'),
                              );
                            }
                          } else {
                            return Center(
                              child: CircularProgressIndicator(color: Colors.blue),
                            );
                          }
                        }),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width - 100,
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          controller: _textController,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade300,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                            hintText: 'Type a message...',
                          ),
                          onChanged: (query) {},
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        tooltip: 'Increase volume by 10',
                        onPressed: () {
                          if (_textController.text.toString() != '') {
                            if (widget.roomId != null) {
                              Map<String, dynamic> data = {
                                'message': _textController.text.trim(),
                                'sent_by': FirebaseAuth.instance.currentUser!.uid,
                                'datetime': DateTime.now(),
                              };
                              firestore.collection('Rooms').doc(widget.roomId).update({
                                'last_message_time': DateTime.now(),
                                'last_message': _textController.text,
                                'sum': messages.length + 1,
                              });
                              firestore.collection('Rooms').doc(widget.roomId).collection('messages').add(data);
                            } else {
                              Map<String, dynamic> data = {
                                'message': _textController.text.trim(),
                                'sent_by': FirebaseAuth.instance.currentUser!.uid,
                                'datetime': DateTime.now(),
                              };
                              firestore.collection('Rooms').add({
                                'Users': [widget.otherUser, FirebaseAuth.instance.currentUser!.uid],
                                'last_message': _textController.text,
                                'last_message_time': DateTime.now(),
                                'sum': 1,
                              }).then((value) async {
                                await firestore.collection('Rooms').doc(value.id).collection('messages').add(data);
                                setState(() {
                                  widget.roomId = value.id;
                                });
                              });
                            }
                          }
                          setState(() {
                            _textController.clear();
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
