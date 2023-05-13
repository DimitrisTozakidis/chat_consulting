import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/models/article.dart';
import 'package:untitled3/utilities/comon_utilities.dart';
import 'package:untitled3/pages/opened_article_page.dart';

import '../blocs/tag_bloc.dart';
import 'add_article_page.dart';
import '../blocs/articles_state.dart';
import '../blocs/tags_state.dart';
import '../blocs/article_bloc.dart';
class ArticleListScreen extends StatefulWidget {
  const ArticleListScreen({Key? key}) : super(key: key);

  @override
  State<ArticleListScreen> createState() => _ArticleListScreenState();

}

class _ArticleListScreenState extends State<ArticleListScreen> {
  late final TagsBloc tagsBloc = context.read<TagsBloc>();
  late final ArticlesBloc articlesBloc = context.read<ArticlesBloc>();
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
    articlesBloc.initialize();
    tagsBloc.initialize();
  }

  @override
  Widget build(BuildContext context) {
    // 1
    return BlocBuilder<TagsBloc, TagState>(
        bloc: tagsBloc,
        builder: (context, tagState) {
          return BlocBuilder<ArticlesBloc, ArticleState>(
            bloc: articlesBloc,
            builder: (context, state) {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: () async {
                    FocusManager.instance.primaryFocus?.unfocus();
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AddArticlePage()),
                    );


                    if (result is Article) {
                      articlesBloc.addNewArticle(result);
                      setState(() {});
                    }
                  },
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.add),
                ),
                appBar: AppBar(title: const Text('My ads')),
                body: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: TextField(
                          decoration: const InputDecoration(border: OutlineInputBorder(), hintText: 'Search ...'),
                          onChanged: (query) {
                            articlesBloc.updateSearchValue(query);
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
                                      if(tagSelected.contains(tagsBloc.state.tags[index].id)){
                                        tagSelected.remove(tagsBloc.state.tags[index].id);
                                      }
                                      else {
                                        tagSelected.add(tagsBloc.state.tags[index].id);
                                      }
                                      articlesBloc.updateTagValue(tagSelected);

                                      setState(() {}
                                      );
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
                      _buildResults()
                    ],
                  ),
                ),
              );
            });
      }
    );
  }

  Widget _buildResults() {
    if (articlesBloc.state.results.isEmpty) {
      return const Center(child: Text('No Results'));
    } else {
      return ListView.builder(
          controller: scrollController,
          shrinkWrap: true,
          itemCount: articlesBloc.state.results.length,
          itemBuilder: (BuildContext context, int index) {
            final List<Widget> articleList = [];
            Color? mainColor = articlesBloc.state.results[index].isRead == true ? Colors.orange[500] : Colors.orange[900];
            articleList.add(
              GestureDetector(
                onTap: () async {
                  articlesBloc.state.results[index].isRead = true;
                  FocusManager.instance.primaryFocus?.unfocus();
                  dynamic tagPressed= await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => OpenedArticlePage(
                              element: articlesBloc.state.results[index],
                            )),
                  );
                  if(tagPressed is int){
                    tagSelected.clear();
                    tagSelected.add(tagPressed);
                    articlesBloc.updateTagValue(tagSelected);

                    setState(() {});
                  }
                  await articlesBloc.openedArticle(articlesBloc.state.results[index]);
                  setState(() {});
                },
                child: Container(
                  decoration: BoxDecoration(color: mainColor, border: Border.all(), borderRadius: const BorderRadius.all(Radius.circular(20))),
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  margin: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Image.network(articlesBloc.state.results[index].image, scale: 40.0),
                          Flexible(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(
                                articlesBloc.state.results[index].title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () async {
                              CommonUtilities.openDeleteDialog(context, articlesBloc.state.results[index], () {
                                articlesBloc.deleteArticle(articlesBloc.state.results[index]);
                                setState(() {});
                                Navigator.pop(context);
                              });
                            },
                            icon: const Icon(Icons.delete_forever),
                          ),
                        ],
                      ),
                      Align(alignment: Alignment.center, child: Text(articlesBloc.state.results[index].description ?? '', textAlign: TextAlign.right, maxLines: 8)),
                      Align(
                        alignment: Alignment.bottomLeft,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.all(16.0),
                            textStyle: const TextStyle(fontSize: 20),
                          ),
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            final dynamic result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AddArticlePage(
                                      article: articlesBloc.state.results[index]
                                      )),
                            ) as Article;

                            if (result is Article) {
                              articlesBloc.updateArticle(result);
                            }

                            setState(() {});
                            //
                            // var animal = Animal();
                            // animal.speak();
                            //
                            // var dog= Dog();
                            // dog.speak();
                          },
                          child: const Text('Edit'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: articleList,
              ),
            );
          });
    }
  }
}
