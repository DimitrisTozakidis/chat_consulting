import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'package:untitled3/messenger/pages/chat_screen.dart';
import 'package:untitled3/type_of_connection.dart';
import 'package:flutterfire_ui/auth.dart';
import 'package:flutterfire_ui/database.dart';
import 'package:flutterfire_ui/firestore.dart';
import 'package:flutterfire_ui/i10n.dart';
import '../../snack_bar.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ScrollController scrollController = ScrollController();
  final String id = ''; //to id tou xristi prepeina mpei edo

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
    } on FirebaseAuthException catch (e) {
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
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                }),
            ListTile(
              leading: Icon(Icons.article),
              title: Text('Ads'),
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
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  'Favorite Users',
                  style: TextStyle(fontSize: 28, color: Colors.white, fontWeight: FontWeight.w500),
                ),
              ),
              SizedBox(height: 8),
              Container(
                height: 91,
                child: ListView.separated(
                  itemCount: 5,
                  scrollDirection: Axis.horizontal,
                  shrinkWrap: true,
                  itemBuilder: (BuildContext context, int index) {
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
                              MaterialPageRoute(builder: (context) => ChatScreen()),
                            );
                          },
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.0),
                            child: Column(
                              children: [
                                Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                                  height: 56,
                                  width: 56,
                                ),
                                Text(
                                  'Dimitrios Tozakidis',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                )
                              ],
                            ),
                          )),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) {
                    return const SizedBox(width: 8);
                  },
                ),
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
                    stream: firestore.collection('Users').doc(FirebaseAuth.instance.currentUser!.uid).collection('Rooms').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if (snapshot.data!.docs.isNotEmpty) {
                          List<QueryDocumentSnapshot?> allData = snapshot.data!.docs
                              .where((element) => element['Users'].contains(id) && element['Users'].contains(FirebaseAuth.instance.currentUser!.uid))
                              .toList();
                          QueryDocumentSnapshot? data = allData.isNotEmpty ? allData.first : null;
                          if (data != null) {
                            setState(() {
                              roomId = data.id;
                            });
                          }
                          return data == null
                              ? Container()
                              : ListView.separated(
                                  itemCount: data['Messages'].length,
                                  scrollDirection: Axis.vertical,
                                  shrinkWrap: true,
                                  itemBuilder: (BuildContext context, int index) {
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
                                              MaterialPageRoute(builder: (context) => ChatScreen()),
                                            );
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(vertical: 8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Container(
                                                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                                                    height: MediaQuery.of(context).size.width * 1 / 7,
                                                    width: MediaQuery.of(context).size.width * 1 / 7),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(
                                                        width: MediaQuery.of(context).size.width / 2,
                                                        child: Text(
                                                          'Dimitrios Tozakidis',
                                                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black),
                                                          overflow: TextOverflow.ellipsis,
                                                        )),
                                                    SizedBox(
                                                      height: 8,
                                                    ),
                                                    SizedBox(
                                                        width: MediaQuery.of(context).size.width / 3,
                                                        child: Text(
                                                          'Wanna go hangout tomorrow at 8 afternoon maybe?',
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
                                                      '2:30',
                                                      style: TextStyle(color: Colors.grey),
                                                    ))
                                              ],
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
