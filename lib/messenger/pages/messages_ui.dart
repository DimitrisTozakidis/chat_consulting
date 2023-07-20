import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled3/messenger/pages/chat_screen.dart';
import 'package:untitled3/messenger/pages/profile_screen.dart';
import '../../articles/pages/article_list_screen.dart';
import '../../utilities/snack_bar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ScrollController scrollController = ScrollController();

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  Future<void> logOut() async {
    try {
      // Sign in with email and password
      await FirebaseAuth.instance.signOut();

      // Navigate to MessengerScreen on successful sign-in
      Navigator.pop(context);
      Navigator.pop(context);
    } on FirebaseAuthException {
      String message;
      message = 'Nooo you will never LEAVE Hahahah';
      showTopSnackBar(
        Overlay.of(context),
        CustomSnackBar.error(
          message: message,
        ),
      );
    }
  }

  Stream<QuerySnapshot> getName() {
    final firestore = FirebaseFirestore.instance;
    return firestore.collection('Users').snapshots();
  }

  late String roomId;

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text(
              'Messages ',
              style: TextStyle(fontSize: 30),
            ),
            Icon(
              Icons.account_box,
              size: 30,
            )
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: SvgPicture.asset(
                color: Colors.orange,
                "assets/chatcommunication.svg",
                height: 180,
              ),
            ),
            ListTile(
              leading: Icon(Icons.message),
              title: Text('Messages'),
            ),
            ListTile(
                leading: Icon(Icons.person),
                title: Text('Profile'),
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreenLocal()));
                }),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('Ads'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArticleListScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async => logOut(),
            ),
          ],
        ),
      ),
      backgroundColor: Color(0xFF4622fe),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Favorite Users',
                  style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 24),
              Container(
                height: 91,
                child: StreamBuilder(
                    stream: firestore.collection('Rooms').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      double? rating;
                      bool isRated = false;
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          List<QueryDocumentSnapshot?> allData =
                              snapshot.data!.docs.where((element) => element['Users'].contains(FirebaseAuth.instance.currentUser!.uid)).toList();
                          QueryDocumentSnapshot? data = allData.isNotEmpty ? allData.first : null;
                          allData.sort((a, b) {
                            // Get the number of docs in the 'messages' collection for each snapshot
                            int aMessageCount = a!['sum'];
                            int bMessageCount = b!['sum'];

                            // Compare the message counts
                            return bMessageCount.compareTo(aMessageCount);
                          });
                          return data == null
                              ? Container()
                              : ListView.separated(
                                  itemCount: allData.length,
                                  scrollDirection: Axis.horizontal,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    String? userTalkingTo;
                                    for (int i = 0; i < 2; i++) {
                                      if (allData[index]!['Users'][i] != FirebaseAuth.instance.currentUser!.uid) {
                                        userTalkingTo = allData[index]!['Users'][i];
                                      }
                                    }
                                    return Container(
                                      height: 83,
                                      width: 100,
                                      child: OutlinedButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            side: MaterialStateProperty.all<BorderSide>(
                                              BorderSide.none, // Remove the outline border
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChatScreen(
                                                        roomId: allData[index]?.id,
                                                        otherUser: userTalkingTo,
                                                        rating: rating,
                                                        isRated: isRated,
                                                      )),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: getName(),
                                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data!.docs.isNotEmpty) {
                                                    List<QueryDocumentSnapshot> allData = snapshot.data!.docs;
                                                    QueryDocumentSnapshot? data;

                                                    for (int i = 0; i < allData.length; i++) {
                                                      data = allData[i];
                                                      if (data['id'] == userTalkingTo) {
                                                        rating = data['review'].toDouble() ?? 0;
                                                        List<dynamic> ratingUsers = data['isRated'];
                                                        for (int j = 0; j < ratingUsers.length; j++) {
                                                          if (ratingUsers[j] == FirebaseAuth.instance.currentUser!.uid) {
                                                            isRated = true;
                                                          }
                                                        }
                                                        return Column(
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                                                              height: 56,
                                                              width: 56,
                                                              child: Text(data['name'][0] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 42)),
                                                            ),
                                                            Text(
                                                              data['name'] ?? '',
                                                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
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
                                          )),
                                    );
                                  },
                                  separatorBuilder: (BuildContext context, int index) {
                                    return const SizedBox(width: 8);
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
            ],
          ),
          SizedBox(
            height: 24,
          ),
          Container(
            padding: EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 4 / 6,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  height: MediaQuery.of(context).size.height * 4 / 6 - 48,
                  child: StreamBuilder(
                    stream: firestore.collection('Rooms').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          List<QueryDocumentSnapshot?> allData =
                              snapshot.data!.docs.where((element) => element['Users'].contains(FirebaseAuth.instance.currentUser!.uid)).toList();
                          QueryDocumentSnapshot? data = allData.isNotEmpty ? allData.first : null;
                          if (data != null) {
                            // roomId = data.id;
                            // Stream<QuerySnapshot<Map<String, dynamic>>> messagesCollection =
                            // firestore.collection('Rooms')
                            //     .doc(data.id)
                            //     .collection('messages').snapshots();
                          }
                          return data == null
                              ? Container()
                              : ListView.separated(
                                  itemCount: allData.length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
                                    double? rating;
                                    bool? isRated = false;
                                    String? userTalkingTo;
                                    DateTime dateTime = allData[index]!['last_message_time'].toDate();
                                    String formattedTime = DateFormat.Hm().format(dateTime);
                                    for (int i = 0; i < 2; i++) {
                                      if (allData[index]!['Users'][i] != FirebaseAuth.instance.currentUser!.uid) {
                                        userTalkingTo = allData[index]!['Users'][i];
                                      }
                                    }
                                    return Container(
                                      height: MediaQuery.of(context).size.height * 1 / 8,
                                      width: 20,
                                      child: OutlinedButton(
                                          style: ButtonStyle(
                                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(20.0),
                                              ),
                                            ),
                                            side: MaterialStateProperty.all<BorderSide>(
                                              BorderSide.none, // Remove the outline border
                                            ),
                                          ),
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => ChatScreen(
                                                        roomId: allData[index]?.id,
                                                        otherUser: userTalkingTo,
                                                        rating: rating,
                                                        isRated: isRated,
                                                      )),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: getName(),
                                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data!.docs.isNotEmpty) {
                                                    List<QueryDocumentSnapshot> allDataUsers = snapshot.data!.docs;
                                                    QueryDocumentSnapshot? data;
                                                    for (int i = 0; i < allDataUsers.length; i++) {
                                                      data = allDataUsers[i];
                                                      if (data['id'] == userTalkingTo) {
                                                        rating = data['review'].toDouble() ?? 0;
                                                        List<dynamic> ratingUsers = data['isRated'];
                                                        for (int j = 0; j < ratingUsers.length; j++) {
                                                          if (ratingUsers[j] == FirebaseAuth.instance.currentUser!.uid) {
                                                            isRated = true;
                                                          }
                                                        }
                                                        return Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Container(
                                                              decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                                                              height: MediaQuery.of(context).size.width * 1 / 7,
                                                              width: MediaQuery.of(context).size.width * 1 / 7,
                                                              child: Text(data['name'][0] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 42)),
                                                            ),
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                SizedBox(
                                                                  width: MediaQuery.of(context).size.width / 2,
                                                                  child: Text(
                                                                    data['name'] ?? '',
                                                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                SizedBox(
                                                                    width: MediaQuery.of(context).size.width / 3,
                                                                    child: Text(
                                                                      allData[index]!['last_message'],
                                                                      softWrap: true,
                                                                      style: TextStyle(fontSize: 15, color: Colors.grey),
                                                                      overflow: TextOverflow.ellipsis,
                                                                      maxLines: 2,
                                                                    )),
                                                              ],
                                                            ),
                                                            Align(
                                                                alignment: Alignment.topRight,
                                                                child: Text(
                                                                  formattedTime,
                                                                  style: TextStyle(color: Colors.grey),
                                                                ))
                                                          ],
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
                                          )),
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
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
