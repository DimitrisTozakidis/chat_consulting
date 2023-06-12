import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../models/article.dart';
import 'articles_state.dart';

class ArticlesBloc extends Cubit<ArticleState> {
  ArticlesBloc() : super(ArticleState());

  updateSearchValue(String searchValue) {
    final List<Article> tagedResults = [];

    for (var element in state.articles) {
      if (state.tagSelected.isEmpty) {
        tagedResults.add(element);
      }
      for (var j = 0; j < state.tagSelected.length; j++) {
        bool tagPressed = element.tags.contains(state.tagSelected[j]);
        if (tagPressed == true) {
          tagedResults.add(element);
        }
      }
    }

    final List<Article> results = [];
    for (var element in tagedResults) {
      bool allToLowerCase = element.title.toUpperCase().contains(searchValue.toUpperCase());
      if (allToLowerCase == true) {
        results.add(element);
      }
    }

    emit(state.copyWith(searchValue: searchValue, results: results));
  }

  updateTagValue(List<int> tagSelected) {
    final List<Article> searchedResults = [];

    for (var element in state.articles) {
      bool allToLowerCase = element.title.toUpperCase().contains(state.searchValue.toUpperCase());
      if (allToLowerCase == true) {
        searchedResults.add(element);
      }
    }

    final List<Article> results = [];
    for (var element in searchedResults) {
      if (tagSelected.isEmpty) {
        results.add(element);
      }
      for (var j = 0; j < tagSelected.length; j++) {
        bool tagPressed = element.tags.contains(tagSelected[j]);
        if (tagPressed == true && !results.contains(element)) {
          results.add(element);
        }
      }
    }

    emit(state.copyWith(tagSelected: tagSelected, results: results));
  }

  initialize() async {
    await getArticles();
  }

  getArticles() async {
    final List<Article> articles = [];
    final firestore = FirebaseFirestore.instance;

    try {
      final snapshot = await firestore.collection('Articles').get();
      if (snapshot.docs.isNotEmpty) {
        final List<QueryDocumentSnapshot> allData = snapshot.docs.toList();
        for (int i = 0; i < allData.length; i++) {
          final List<dynamic> tagsData = allData[i]['tags'];
          final List<int> tags = tagsData.cast<int>(); // Cast tags to List<int>
          final snapshotSecond = await FirebaseFirestore.instance.collection('Users').get();
          String? tagName;

          snapshotSecond.docs.forEach((doc) {
            if (doc.data()['id'] == allData[i]['writer']) {
              tagName = doc.data()['name'];
            }
          });

          Article test = Article(
            title: allData[i]['title'],
            description: allData[i]['description'],
            id: allData[i].id,
            isRead: allData[i]['isRead'],
            tags: tags,
            writer: tagName ?? allData[i]['writer'],
            writerId: allData[i]['writerId']
          );
          articles.add(test);
        }
        emit(state.copyWith(articles: articles, results: articles));
      } else {
        emit(state.copyWith(articles: [])); // No articles found
      }
    } catch (error) {
      print('Error fetching articles: $error');
      emit(state.copyWith(articles: [])); // Error occurred while fetching articles
    }
  }

  addNewArticle(Article article) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Articles').add({
        'title': article.title,
        'description': article.description,
        'isRead': article.isRead,
        'tags': article.tags,
        'writer': article.writer,
        'writerId': article.writerId

      });
      await getArticles();
    } catch (error) {
      print('Error adding article: $error');
    }

    updateSearchValue(state.searchValue);
  }

  updateArticle(Article article) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Articles').doc(article.id).update({
        'title': article.title,
        'description': article.description,
        'isRead': article.isRead,
        'tags': article.tags,
        'writer': article.writer,
        'writerId': article.writerId,
      });
      await getArticles();
    } catch (error) {
      print('Error updating article: $error');
    }

    updateSearchValue(state.searchValue);
  }

  editArticle(
    int id,
    String title,
    String? description,
  ) async {
    final firestore = FirebaseFirestore.instance;
    final List<Article> articles = state.articles;
    Article? foundArticle;

    for (int i = 0; i < articles.length; i++) {
      if (articles[i].id == id) {
        foundArticle = articles[i];
        foundArticle.title = title;
        foundArticle.description = description;

        articles.replaceRange(i, i + 1, [foundArticle]);
        break;
      }
    }
    try {
      await firestore.collection('Articles').doc(foundArticle!.id).update({
        'title': foundArticle.title,
        'description': foundArticle.description,
      });
      await getArticles();
    } catch (error) {
      print('Error updating article in Firestore: $error');
    }

    updateSearchValue(state.searchValue);
  }

  deleteArticle(Article article) async {
    final firestore = FirebaseFirestore.instance;
    final List<Article> articles = state.articles;

    try {
      // Find the index of the article to delete
      final int deleteIndex = articles.indexWhere((articleToDel) => articleToDel.id == article.id);

      // If the article is found, remove it from the list and delete it from Firestore
      if (deleteIndex != -1) {
        final Article deletedArticle = articles[deleteIndex];
        articles.removeAt(deleteIndex);

        await firestore.collection('Articles').doc(deletedArticle.id).delete();
        await getArticles();
      }
    } catch (error) {
      print('Error deleting article from Firestore: $error');
    }
    articles.remove(article);

    updateSearchValue(state.searchValue);
  }

  openedArticle(Article article) async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('Articles').doc(article.id).update({
        'title': article.title,
        'description': article.description,
        'isRead': article.isRead,
        'tags': article.tags,
        'writer': article.writer,
        'writerId': article.writerId,
      });
      await getArticles();
    } catch (error) {
      print('Error updating article: $error');
    }

    updateSearchValue(state.searchValue);
    updateTagValue(state.tagSelected);
  }
}
