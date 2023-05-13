import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:untitled3/models/article.dart';
import 'package:untitled3/blocs/articles_state.dart';

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
    try {
      final dio = Dio();
      final response = await dio.get('http://192.168.2.3:3000/articles');
      final List<dynamic> list = response.data;

      for (var element in list) {
        articles.add(Article.fromJson(element));
      }
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    emit(state.copyWith(articles: articles, results: articles));
  }

  addNewArticle(Article article) async {
    try {
      final dio = Dio();
      await dio.post('http://192.168.2.3:3000/articles', data: {
        "title": article.title,
        "description": article.description,
        "tags": article.tags,
        "image": "https://picsum.photos/2000/2000?random=${state.articles.length}"
      });
      await getArticles();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    updateSearchValue(state.searchValue);
  }

  updateArticle(Article article) async {
    try {
      final dio = Dio();
      await dio.put('http://192.168.2.3:3000/articles/${article.id}', data: article.toJson());
      await getArticles();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    updateSearchValue(state.searchValue);
  }

  editArticle(
    int id,
    String title,
    String? description,
  ) async {
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
      final dio = Dio();
      await dio.put('http://192.168.2.3:3000/articles/$id', data: {"id": id, "title": title, "description": description, "image": foundArticle?.image});
      await getArticles();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    updateSearchValue(state.searchValue);
  }

  deleteArticle(Article article) async {
    final List<Article> articles = state.articles;

    try {
      final dio = Dio();
      await dio.delete('http://192.168.2.3:3000/articles/${article.id}', data: {"id": article.id});
      await getArticles();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }
    articles.remove(article);

    updateSearchValue(state.searchValue);
  }

  openedArticle(Article article) async {
    try {
      final dio = Dio();
      article.isRead = true;
      await dio.put('http://192.168.2.3:3000/articles/${article.id}', data: article.toJson());
      await getArticles();
    } catch (error) {
      if (kDebugMode) {
        print(error);
      }
    }

    updateSearchValue(state.searchValue);
    updateTagValue(state.tagSelected);
  }
}
