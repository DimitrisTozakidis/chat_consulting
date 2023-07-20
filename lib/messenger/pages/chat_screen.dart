import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import 'package:intl/intl.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  ChatScreen({Key? key, required this.roomId, required this.otherUser, this.rating, this.isRated}) : super(key: key);

  late String? roomId;
  final String? otherUser;
  final double? rating;
  final bool? isRated;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  final List<Message> messages = [];
  late bool? isRated;
  List<dynamic> ratingUsers = [];
  double reviewNumber = 0;
  late String otherUserId = '';
  final _textController = TextEditingController();
  late String name = ' ';

  @override
  void dispose() {
    scrollController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    isRated = widget.isRated;
    updateRatings();
  }

  void updateRatings() {
    final firestore = FirebaseFirestore.instance;

    Stream<QuerySnapshot> stream = getName();
    stream.listen((snapshot) {
      if (snapshot.docs.isNotEmpty) {
        List<QueryDocumentSnapshot> allData = snapshot.docs;
        QueryDocumentSnapshot? data;
        for (int i = 0; i < allData.length; i++) {
          data = allData[i];
          if (data['id'] == widget.otherUser) {
            // Process the data here
            ratingUsers = data['isRated'];
            otherUserId = data.id;
            reviewNumber = data['review_number'].toDouble();
            break; // Exit the loop if a matching data is found
          }
        }
      } else {
        print('No user found');
      }
    }, onError: (error) {
      print('Error: $error');
    });
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
    final roomRef = FirebaseFirestore.instance.collection('Rooms').doc(widget.roomId);
    // 1
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: getName(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.docs.isNotEmpty) {
                    List<QueryDocumentSnapshot> allData = snapshot.data!.docs;
                    QueryDocumentSnapshot? data;
                    for (int i = 0; i < allData.length; i++) {
                      data = allData[i];
                      if (data['id'] == widget.otherUser) {
                        name = data['name'] ?? '';
                        return Text(
                          data['name'] ?? '',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
                          overflow: TextOverflow.ellipsis,
                        );
                      }
                    }
                    // Return a default widget if no matching data is found
                    return Container();
                  } else {
                    return Center(
                      child: Text('No name found'),
                    );
                  }
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.blue),
                  );
                }
              },
            ),
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
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    'Rate the user',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                RatingBar.builder(
                  initialRating: widget.rating ?? 0,
                  minRating: 1,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  ignoreGestures: isRated ?? false,
                  itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                  itemBuilder: (context, _) => Icon(
                    Icons.star,
                    color: (isRated ?? false) ? Colors.blue : Colors.amber,
                  ),
                  onRatingUpdate: (rating) {
                    setState(() {
                      isRated = true;

                      ratingUsers.add(FirebaseAuth.instance.currentUser!.uid);
                      double newRating = ((widget.rating ?? 0) * reviewNumber + rating) / (reviewNumber + 1);
                      // Update the rating data in Firestore
                      firestore.collection('Users').doc(otherUserId).update({
                        'review': newRating,
                        'review_number': reviewNumber + 1,
                        'isRated': ratingUsers,
                      });
                    });
                  },
                ),
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 1 / 6 - 48),
            Container(
              padding: EdgeInsets.all(24),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 9 / 12 - 88,
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
                                  // DateTime dateTime = allData[i]!['datetime'].toDate();
                                  // String formattedTime = DateFormat.Hm().format(dateTime);
                                  messages.add(
                                    Message(
                                      text: allData[i]!['message'],
                                      mine: allData[i]!['sent_by'] == FirebaseAuth.instance.currentUser!.uid,
                                      time: allData[i]!['datetime'].toDate(),
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
                                                    DateFormat.Hm().format(messages[index].time),
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
                                                      width: MediaQuery.of(context).size.width * 1 / 8,
                                                      child: Text(name[0], textAlign: TextAlign.center, style: TextStyle(fontSize: 37)),
                                                    ),
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
