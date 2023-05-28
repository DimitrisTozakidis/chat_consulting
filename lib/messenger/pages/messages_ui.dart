import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:untitled3/messenger/pages/chat_screen.dart';
import 'package:untitled3/type_of_connection.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({Key? key}) : super(key: key);

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final ScrollController scrollController = ScrollController();
  final List<int> tagSelected = [];

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TypeOfConnection _typeOfConnection;

    // 1
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
      backgroundColor: Color(0xFF4622fe),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
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
                  child: ListView.separated(
                    itemCount: 10,
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
                              padding:  EdgeInsets.symmetric(vertical: 8.0),
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
                                  Align(alignment: Alignment.topRight, child: Text('2:30',style: TextStyle(color: Colors.grey),))
                                ],
                              ),
                            )),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) {
                      return const SizedBox(height: 8);
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
