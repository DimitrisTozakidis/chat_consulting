import 'package:flutter/material.dart';
import 'package:untitled3/type_of_connection.dart';

import 'package:intl/intl.dart';
import '../models/message.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController scrollController = ScrollController();
  final List<Message> messages = [];
  final Message one = Message(text: 'Hi,Baby', mine: false, time: DateTime(2012, 1, 1, 12, 2));
  final Message two = Message(text: "You 're kavla", mine: false, time: DateTime(2012, 1, 1, 12, 2));
  final Message three = Message(text: 'Yea...', mine: true, time: DateTime(2012, 1, 1, 12, 3));
  final Message four = Message(text: 'I know daa', mine: true, time: DateTime(2012, 1, 1, 12, 3));
  final Message five = Message(text: "You 're kavla", mine: false, time: DateTime(2012, 1, 1, 12, 2));
  final Message six = Message(text: 'I know daaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa', mine: true, time: DateTime(2012, 1, 1, 12, 3));

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
    messages.add(one);
    messages.add(two);
    messages.add(three);
    messages.add(four);
    messages.add(five);
    messages.add(six);
  }

  @override
  Widget build(BuildContext context) {
    TypeOfConnection _typeOfConnection;

    // 1
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text(
              'Name Surname',
              style: TextStyle(fontSize: 20),
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
                    child: ListView.separated(
                      itemCount: messages.length,
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
                                    DateFormat('HH:mm').format(messages[index].time),
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
                                height: 48,
                              )
                          ],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return const SizedBox(height: 8);
                      },
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width- 100,
                        child: TextField(
                          textInputAction: TextInputAction.done,
                          controller: _textController,
                          decoration: InputDecoration(filled: true,
                            fillColor: Colors.grey.shade300,  border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), hintText: 'Type a message...',),
                          onChanged: (query) {},
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        tooltip: 'Increase volume by 10',
                        onPressed: () {
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
