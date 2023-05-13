import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/models/article.dart';
import '../blocs/tag_bloc.dart';
import '../blocs/tags_state.dart';

class AddArticlePage extends StatefulWidget {
  const AddArticlePage({super.key, this.article});

  final Article? article;

  @override
  State<AddArticlePage> createState() => _AddArticlePageState();
}

class _AddArticlePageState extends State<AddArticlePage> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final List<int> tagSelected = [];

  bool isChecked = false;
  late final TagsBloc tagsBloc = context.read<TagsBloc>();

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (widget.article != null) {
      titleController.text = widget.article!.title;
      descriptionController.text = widget.article!.description ?? "";

      for (int index = 0; index < widget.article!.tags.length; index++) {
        for (int i = 0; i < tagsBloc.state.tags.length; i++) {
          if (widget.article?.tags[index] == tagsBloc.state.tags[i].id) {
            tagSelected.add(tagsBloc.state.tags[i].id);
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TagsBloc, TagState>(
        bloc: tagsBloc,
        builder: (context, state) {
          (Set<MaterialState> states) {
            const Set<MaterialState> interactiveStates = <MaterialState>{
              MaterialState.pressed,
              MaterialState.hovered,
              MaterialState.focused,
            };
            if (states.any(interactiveStates.contains)) {
              return Colors.blue;
            }
            return Colors.red;
          };

          return Scaffold(
            appBar: AppBar(
              title: Text(widget.article == null ? 'Add Article' : 'Edit Article'),
            ),
            body: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Enter title ...'),
                      onChanged: (query) {
                        setState(() {});
                        //articlesBloc.updateSearchValue(query);
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    //margin: const EdgeInsets.all(20),
                    child: TextField(
                      controller: descriptionController,

                      decoration:
                          const InputDecoration(border: OutlineInputBorder(), contentPadding: EdgeInsets.symmetric(vertical: 40), hintText: 'Enter description ...'),
                      maxLines: 8,
                      // <-- SEE HERE
                      minLines: 1,
                      // <-- SEE HERE
                      onChanged: (query) {
                        // var value = query.data;
                        //articlesBloc.updateSearchValue(query);
                      },
                    ),
                  ),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                    const Text("Tags",
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        )),
                    SizedBox(
                      height: 46,
                      width: 250,
                      child: ListView.separated(
                        itemCount: tagsBloc.state.tags.length,
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          //final color = tagsBloc.state.tags[index].color.toColor();
                          Color? mainColor = tagSelected.contains(tagsBloc.state.tags[index].id) ? Colors.orange[500] : Colors.orange[900];
                          return Row(
                            children: [
                              OutlinedButton(
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  foregroundColor: Colors.blue,
                                  backgroundColor: mainColor,
                                  side: const BorderSide(width: 3, color: Colors.red),
                                ),
                                onPressed: () {
                                  if (tagSelected.contains(tagsBloc.state.tags[index].id)) {
                                    tagSelected.remove(tagsBloc.state.tags[index].id);
                                  } else {
                                    tagSelected.add(tagsBloc.state.tags[index].id);
                                  }

                                  setState(() {});
                                },
                                child: Text(tagsBloc.state.tags[index].title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          );
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const SizedBox(width: 8);
                        },
                      ),
                    ),
                  ]),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: ElevatedButton(
                      onPressed: titleController.text.isEmpty || tagSelected.isEmpty || tagSelected.isEmpty
                          ? null
                          : () {
                              Article article = Article(
                                  id: widget.article?.id,
                                  image: ('https://picsum.photos/2000/2000?random=${Random().nextInt(100000)}'),
                                  title: titleController.text,
                                  tags: tagSelected,
                                  description: descriptionController.text);
                              Navigator.pop(context, article);
                            },
                      child: Text(widget.article == null ? 'Add Article' : 'Edit Article'),
                    ),
                  )
                ],
              ),
            ),
          );
        });
  }
}
