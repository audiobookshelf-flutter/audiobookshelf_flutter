import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/material_ui/features/book_details/book_details_view.dart';
import 'package:audiobookshelf/material_ui/features/books/books_view.dart';
import 'package:audiobookshelf/material_ui/features/home/home_view.dart';
import 'package:audiobookshelf/material_ui/features/authors/authors_view.dart';
import 'package:audiobookshelf/material_ui/features/player/player_view.dart';
import 'package:audiobookshelf/material_ui/features/collections/collections_view.dart';
import 'package:audiobookshelf/material_ui/features/series/series_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.Home:
        return MaterialPageRoute(builder: (_) => HomeView());
      case Routes.Authors:
        return MaterialPageRoute(builder: (_) => AuthorsView());
      case Routes.Books:
        return MaterialPageRoute(builder: (_) => BooksView());
      case Routes.Collections:
        return MaterialPageRoute(builder: (_) => CollectionsView());
      case Routes.Series:
        return MaterialPageRoute(builder: (_) => SeriesView());
      case Routes.Author:
        Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => BooksView(
                  mediaId: args!['id'],
                  title: args['title'],
                ));
      case Routes.Book:
        return MaterialPageRoute(
          builder: (_) => BookDetailsView(
            mediaId: settings.arguments as String,
          ),
        );
      case Routes.Player:
        return MaterialPageRoute(
            builder: (_) => PlayerView(
                  book: settings.arguments as MediaItem,
                ));
      default:
        return MaterialPageRoute(builder: (_) => HomeView());
    }
  }
}
