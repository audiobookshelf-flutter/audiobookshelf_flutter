import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/ui/features/book_details/book_details_view.dart';
import 'package:audiobookshelf/ui/features/library/library_view.dart';
import 'package:audiobookshelf/ui/features/home/home_view.dart';
import 'package:audiobookshelf/ui/features/authors/authors_view.dart';
import 'package:audiobookshelf/ui/features/player/player_view.dart';
import 'package:audiobookshelf/ui/features/collections/collections_view.dart';
import 'package:audiobookshelf/ui/features/series/series_view.dart';
import 'package:flutter/material.dart';

class Router {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case Routes.home:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case Routes.authors:
        return MaterialPageRoute(builder: (_) => const AuthorsView());
      case Routes.library:
        return MaterialPageRoute(builder: (_) => const LibraryView());
      case Routes.collections:
        return MaterialPageRoute(builder: (_) => const CollectionsView());
      case Routes.series:
        return MaterialPageRoute(builder: (_) => const SeriesView());
      case Routes.author:
        Map<String, dynamic>? args =
            settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
            builder: (_) => LibraryView(
                  mediaId: args!['id'],
                  title: args['title'],
                ));
      case Routes.book:
        return MaterialPageRoute(
          builder: (_) => BookDetailsView(
            mediaId: settings.arguments as String,
          ),
        );
      case Routes.player:
        return MaterialPageRoute(
            builder: (_) => PlayerView(
                  book: settings.arguments as MediaItem,
                ));
      default:
        return MaterialPageRoute(builder: (_) => const HomeView());
    }
  }
}