import '../models/article.dart';

class ArticleState {
  ArticleState({
    this.searchValue = '',
    this.status = ArticleStatus.idle,
    this.tagSelected = const [],
    this.articles = const [],
    this.results = const [],
  });

  String searchValue;
  ArticleStatus status;
  List<Article> articles;
  List<Article> results;
  List<int> tagSelected;

  ArticleState copyWith({
    String? searchValue,
    ArticleStatus? status,
    List<Article>? articles,
    List<Article>? results,
    List<int>? tagSelected,
  }) {
    return ArticleState(
        searchValue: searchValue ?? this.searchValue,
        status: status ?? this.status,
        articles: articles ?? this.articles,
        tagSelected: tagSelected ?? this.tagSelected,
        results: results ?? this.results);
  }
}

enum ArticleStatus { idle, searchResults }
