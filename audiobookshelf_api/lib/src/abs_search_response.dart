import 'dart:convert';

import 'package:audiobookshelf_api/audiobookshelf_api.dart';
import 'package:audiobookshelf_api/src/abs_audiobook_search_result.dart';
import 'package:audiobookshelf_api/src/abs_series_search_result.dart';

_listEquals(List a, List b) => a.join(',') == b.join(',');

class AbsSearchResponse {
  final List<AbsAudiobookSearchResult> book;
  final List<dynamic> tags;
  final List<Author> authors;
  final List<AbsSeriesSearchResult> series;
  AbsSearchResponse({
    required this.book,
    required this.tags,
    required this.authors,
    required this.series,
  });

  AbsSearchResponse copyWith({
    List<AbsAudiobookSearchResult>? book,
    List<dynamic>? tags,
    List<Author>? authors,
    List<AbsSeriesSearchResult>? series,
  }) {
    return AbsSearchResponse(
      book: book ?? this.book,
      tags: tags ?? this.tags,
      authors: authors ?? this.authors,
      series: series ?? this.series,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'book': book.map((x) => x.toJson()).toList(),
      'tags': tags,
      'authors': authors.map((x) => x.toJson()).toList(),
      'series': series.map((x) => x.toMap()).toList(),
    };
  }

  factory AbsSearchResponse.fromMap(Map<String, dynamic> map) {
    return AbsSearchResponse(
      book: List<AbsAudiobookSearchResult>.from(
          map['book']?.map((x) => AbsAudiobookSearchResult.fromJson(x))),
      tags: List<dynamic>.from(map['tags'] ?? []),
      authors:
          List<Author>.from(map['authors']?.map((x) => Author.fromJson(x))),
      series: List<AbsSeriesSearchResult>.from(
          map['series']?.map((x) => AbsSeriesSearchResult.fromMap(x))),
    );
  }

  String toJson() => json.encode(toMap());

  factory AbsSearchResponse.fromJson(String source) =>
      AbsSearchResponse.fromMap(json.decode(source));

  @override
  String toString() {
    return 'AbsSearchResponse(audiobooks: $book, tags: $tags, authors: $authors, series: $series)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is AbsSearchResponse &&
        _listEquals(other.tags, tags) &&
        _listEquals(other.authors, authors) &&
        _listEquals(other.series, series);
  }

  @override
  int get hashCode {
    return book.hashCode ^ tags.hashCode ^ authors.hashCode ^ series.hashCode;
  }
}

class Audiobook {
  final Audiobook audiobook;
  final String matchKey;
  final String matchText;
  Audiobook({
    required this.audiobook,
    required this.matchKey,
    required this.matchText,
  });

  Audiobook copyWith({
    Audiobook? audiobook,
    String? matchKey,
    String? matchText,
  }) {
    return Audiobook(
      audiobook: audiobook ?? this.audiobook,
      matchKey: matchKey ?? this.matchKey,
      matchText: matchText ?? this.matchText,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'audiobook': audiobook.toJson(),
      'matchKey': matchKey,
      'matchText': matchText,
    };
  }

  factory Audiobook.fromMap(Map<String, dynamic> map) {
    return Audiobook(
      audiobook: Audiobook.fromMap(map['audiobook']),
      matchKey: map['matchKey'],
      matchText: map['matchText'],
    );
  }

  String toJson() => json.encode(toMap());

  factory Audiobook.fromJson(String source) =>
      Audiobook.fromMap(json.decode(source));

  @override
  String toString() =>
      'Audiobook(audiobook: $audiobook, matchKey: $matchKey, matchText: $matchText)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Audiobook &&
        other.audiobook == audiobook &&
        other.matchKey == matchKey &&
        other.matchText == matchText;
  }

  @override
  int get hashCode =>
      audiobook.hashCode ^ matchKey.hashCode ^ matchText.hashCode;
}

class _Author {
  final String author;
  _Author({
    required this.author,
  });

  _Author copyWith({
    String? author,
  }) {
    return _Author(
      author: author ?? this.author,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'author': author,
    };
  }

  factory _Author.fromMap(Map<String, dynamic> map) {
    return _Author(
      author: map['author'],
    );
  }

  String toJson() => json.encode(toMap());

  factory _Author.fromJson(String source) =>
      _Author.fromMap(json.decode(source));

  @override
  String toString() => '_Author(author: $author)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is _Author && other.author == author;
  }

  @override
  int get hashCode => author.hashCode;
}
