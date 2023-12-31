import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/messenger/pages/chat_screen.dart';

import '../blocs/tag_bloc.dart';
import '../models/article.dart';
import '../utilities/comon_utilities.dart';
import 'add_article_page.dart';
import '../blocs/articles_state.dart';
import '../blocs/article_bloc.dart';

class OpenedArticlePage extends StatefulWidget {
  const OpenedArticlePage({Key? key, required this.element}) : super(key: key);

  final Article element;

  @override
  State<OpenedArticlePage> createState() => _OpenedArticlePageState();
}

class _OpenedArticlePageState extends State<OpenedArticlePage> {
  late final TagsBloc tagsBloc = context.read<TagsBloc>();
  late final ArticlesBloc articlesBloc = context.read<ArticlesBloc>();
  late final String image;

  @override
  void initState() {
    super.initState();
    tagsBloc.initialize();

    for (int i = 0; i < tagsBloc.state.tags.length; i++) {
      if (widget.element.tags[0] == tagsBloc.state.tags[i].id) {
        image = tagsBloc.state.tags[i].image;
      }
    }
  }

  Stream<QuerySnapshot> getName() {
    final firestore = FirebaseFirestore.instance;
    return firestore.collection('Users').snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ArticlesBloc, ArticleState>(
      bloc: context.read<ArticlesBloc>(),
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.white,
          floatingActionButton: FirebaseAuth.instance.currentUser!.uid == widget.element.writerId
              ? null
              : FloatingActionButton(
                  onPressed: () async {
                    final firestore = FirebaseFirestore.instance;
                    final snapshot = await firestore.collection('Rooms').get();
                    QueryDocumentSnapshot<Map<String, dynamic>>? data;
                    try {
                      data = snapshot.docs.firstWhere(
                          (element) => element['Users'].contains(FirebaseAuth.instance.currentUser!.uid) && element['Users'].contains(widget.element.writerId));
                    } catch (e) {
                      data = null;
                    }
                    final snapshotForRating = await firestore.collection('Users').get();
                    QueryDocumentSnapshot<Map<String, dynamic>>? dataForRating;
                    try {
                      dataForRating = snapshotForRating.docs.firstWhere((element) => element['id'].contains(widget.element.writerId));
                    } catch (e) {
                      dataForRating = null;
                    }

                    double review = dataForRating?['review'];
                    bool isRated = false;
                    List<dynamic> ratingUsers = dataForRating?['isRated'];
                    for (int j = 0; j < ratingUsers.length; j++) {
                      if (ratingUsers[j] == FirebaseAuth.instance.currentUser!.uid) {
                        isRated = true;
                      }
                    }
                    String? roomId = data?.id;
                    FocusManager.instance.primaryFocus?.unfocus();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ChatScreen(
                                roomId: roomId,
                                otherUser: widget.element.writerId,
                                isRated: isRated,
                                rating: review,
                              )),
                    );
                  },
                  backgroundColor: Colors.green,
                  child: const Text('Answer'),
                ),
          body: SafeArea(
            top: false,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Stack(
                    children: [
                      Container(
                        height: 400,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          boxShadow: [BoxShadow(color: Colors.grey.shade600, spreadRadius: 30, blurRadius: 20)],
                          borderRadius: const BorderRadius.all(Radius.circular(18.0)),
                          image: DecorationImage(image: AssetImage(image), fit: BoxFit.cover),
                        ),
                        //child: const RiveAnimation.asset("assets/vehicles.riv", fit: BoxFit.cover),
                      ),
                      SizedBox(
                        height: 400,
                        child: Padding(
                          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  IconButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                  ),
                                  Row(
                                    children: [
                                      PopupMenuButton(
                                          color: Colors.white,
                                          itemBuilder: (context) {
                                            return [
                                              const PopupMenuItem<int>(
                                                value: 0,
                                                child: Text("Add new"),
                                              ),
                                              const PopupMenuItem<int>(
                                                value: 1,
                                                child: Text("Edit"),
                                              ),
                                              const PopupMenuItem<int>(
                                                value: 2,
                                                child: Text("Delete"),
                                              ),
                                            ];
                                          },
                                          onSelected: FirebaseAuth.instance.currentUser!.uid != widget.element.writerId
                                              ? null
                                              : (value) async {
                                                  if (value == 0) {
                                                    final dynamic result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => const AddArticlePage()),
                                                    );

                                                    if (result is Article) {
                                                      articlesBloc.addNewArticle(result);
                                                      setState(() {});
                                                    }
                                                  } else if (value == 1) {
                                                    setState(() {});
                                                    final dynamic result = await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) => AddArticlePage(article: widget.element)),
                                                    ) as Article;
                                                    setState(() {});

                                                    if (result is Article) {
                                                      articlesBloc.updateArticle(result);
                                                      setState(() {});
                                                    }
                                                    setState(() {});
                                                  } else if (value == 2) {
                                                    CommonUtilities.openDeleteDialog(context, widget.element, () {
                                                      articlesBloc.deleteArticle(widget.element);
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                      Navigator.pop(context);
                                                      setState(() {});
                                                    });
                                                  }
                                                  setState(() {});
                                                }),
                                    ],
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.only(left: 18.0, bottom: 8),
                                          child: CircleAvatar(
                                            backgroundColor: Colors.white,
                                            radius: 30,
                                            child: StreamBuilder<QuerySnapshot>(
                                              stream: getName(),
                                              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                                                if (snapshot.hasData) {
                                                  if (snapshot.data!.docs.isNotEmpty) {
                                                    List<QueryDocumentSnapshot> allData = snapshot.data!.docs;
                                                    QueryDocumentSnapshot? data;

                                                    for (int i = 0; i < allData.length; i++) {
                                                      data = allData[i];
                                                      if (data['id'] == widget.element.writerId) {
                                                        return Container(
                                                          decoration: BoxDecoration(borderRadius: BorderRadius.circular(90), color: Colors.red),
                                                          height: 50,
                                                          width: 50,
                                                          child: Text(data['name'][0] ?? '', textAlign: TextAlign.center, style: TextStyle(fontSize: 42)),
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
                                          ),
                                        ),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 12.0),
                                      child: Row(
                                        children: [
                                          Column(
                                            children: [
                                              Text(getCurrentDateMonthDay().toString(),
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20,
                                                  )),
                                              Text.rich(
                                                TextSpan(
                                                  style: const TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 35,
                                                  ),
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      text: getCurrentDateYear().toString().substring(0, 3),
                                                      style: const TextStyle(
                                                        decoration: TextDecoration.underline,
                                                        decorationColor: Colors.blue,
                                                        decorationThickness: 2.5,
                                                      ),
                                                    ),
                                                    TextSpan(
                                                      text: getCurrentDateYear().toString().substring(3),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(widget.element.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 38,
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(left: 60.0, bottom: 20),
                                child: Row(
                                  children: [
                                    Text.rich(
                                      TextSpan(
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20,
                                          ),
                                          children: [
                                            TextSpan(text: "By ", style: TextStyle(color: Colors.grey)),
                                            TextSpan(text: widget.element.writer, style: TextStyle(color: Colors.white)),
                                          ]),
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 0.0, top: 16, right: 0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      const Text("Tags",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          )),
                      SizedBox(
                        height: 30,
                        width: 250,
                        child: ListView.separated(
                          itemCount: widget.element.tags.length,
                          scrollDirection: Axis.horizontal,
                          shrinkWrap: true,
                          itemBuilder: (BuildContext context, int index) {
                            String title = "";
                            for (int i = 0; i < tagsBloc.state.tags.length; i++) {
                              if (widget.element.tags[index] == tagsBloc.state.tags[i].id) {
                                title = tagsBloc.state.tags[i].title;
                              }
                            }

                            return OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  foregroundColor: Colors.blue,
                                  side: BorderSide(width: 3, color: tagsBloc.state.tags[index].color)),
                              onPressed: () {
                                Navigator.pop(context, widget.element.tags[index]);
                              },
                              child: Text(title, style: TextStyle(color: tagsBloc.state.tags[index].color, fontSize: 15, fontWeight: FontWeight.w600)),
                            );
                          },
                          separatorBuilder: (BuildContext context, int index) {
                            return const SizedBox(width: 8);
                          },
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 38.0, left: 30, right: 25),
                    child: Text(
                      widget.element.description ?? '',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

String getCurrentDateMonthDay() {
  var date = DateTime.now().toString();

  var dateParse = DateTime.parse(date);

  const Map<int, String> monthsInYear = {1: "JAN", 2: "FEB", 3: "MAR", 4: "APR", 5: "MAY", 6: "JUN", 7: "JUL", 8: "AUG", 9: "SEP", 10: "OCT", 11: "NOV", 12: "DEC"};

  var formattedDate = "${monthsInYear[dateParse.month]} ${dateParse.day} ";
  return formattedDate.toString();
}

String getCurrentDateYear() {
  var date = DateTime.now().toString();

  var dateParse = DateTime.parse(date);

  var formattedDate = "${dateParse.year}";
  return formattedDate.toString();
}
