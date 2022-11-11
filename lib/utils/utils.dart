import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/models/book.dart';
import 'package:audiobookshelf/models/track.dart';
import 'package:audiobookshelf/models/chapter.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class Utils {
  static String getTimeValue(Duration? time) {
    if (time == null) return '-:--:--';
    return RegExp(r'((^0*[1-9]\d*:)?\d{2}:\d{2})')
            .firstMatch("$time")
            ?.group(1) ??
        '$time';
  }

  static Future<Directory?> getBasePath() async {
    try {
      return await getApplicationDocumentsDirectory();
    } catch (e) {
      return await getApplicationDocumentsDirectory();
    }
  }

  static MediaItem chapterToItem(Chapter chapter) {
    return MediaItem(
        id: chapter.id,
        title: chapter.title,
        duration: Duration(
              milliseconds: (chapter.end * 1000).round(),
            ) -
            Duration(
              milliseconds: (chapter.start * 1000).round(),
            ),
        extras: {'start': chapter.start, 'end': chapter.end});
  }

  static String format(Duration d) =>
      d.toString().split('.').first.padLeft(8, "0");
  static String cleanPath(String path) =>
      path.replaceAll(RegExp(r'([^a-zA-Z0-9 /\.]+)'), '-');
  static String cleanFileName(String fileName) =>
      fileName.replaceAll(RegExp(r'([^a-zA-Z0-9 \.]+)'), '-');

  static double getProgress({MediaItem? item, Book? book}) {
    if (book != null && book.duration != Duration.zero) {
      return book.lastPlayedPosition.inMilliseconds /
          book.duration.inMilliseconds;
    } else if (item != null) {
      return item.duration != null
          ? item.viewOffset.inMilliseconds / item.duration!.inMilliseconds
          : 0;
    }
    return 0;
  }

  static bool isLargeScreen(BuildContext context) {
    return MediaQuery.of(context).size.width > 640.0;
  }

  static String friendlyDuration(Duration duration) {
    int hours = duration.inHours;
    int minutes = duration.inMinutes.remainder(60);
    final hoursText = hours > 0 ? '$hours hour${hours != 1 ? "s" : ""}' : '';
    final minutesText =
        minutes > 0 ? '$minutes minute${minutes != 1 ? "s" : ""}' : '';
    List<String> pieces = [];
    if (hoursText.isNotEmpty) pieces.add(hoursText);
    if (minutesText.isNotEmpty) pieces.add(minutesText);
    return pieces.join(' and ');
  }

  static String friendlyDurationFromItems(List<MediaItem> items) {
    final totalDuration = items.fold<Duration>(
        Duration.zero,
        (previousValue, element) =>
            previousValue + (element.duration ?? Duration.zero));
    return friendlyDuration(totalDuration);
  }
}

extension ListHelpers<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}

extension StringHelpers on String {
  Uri? get uri => Uri.parse(this);
  int get fastHash {
    var hash = 0xcbf29ce484222325;

    var i = 0;
    while (i < length) {
      final codeUnit = codeUnitAt(i++);
      hash ^= codeUnit >> 8;
      hash *= 0x100000001b3;
      hash ^= codeUnit & 0xFF;
      hash *= 0x100000001b3;
    }

    return hash;
  }
}

extension MediaHelpers on MediaItem {
  String? get narrator => extras?['narrator'];
  bool get played => extras?['played'] ?? false;
  bool get cached => extras?['cached'] ?? false;
  bool get downloading => extras?['downloading'] ?? false;
  double get downloadProgress => extras?['downloadProgress'] ?? 0.0;
  String get cachePath => extras?['cachePath'] ?? '';
  String get asin => extras?['asin'] ?? '';

  String? get partKey => extras?['partKey'];

  Duration get viewOffset => extras?['viewOffset'] == null
      ? Duration.zero
      : Duration(milliseconds: extras?['viewOffset']);

  Duration get currentTrackStartingPosition =>
      extras?['currentTrackStartingPosition'] == null
          ? Duration.zero
          : Duration(milliseconds: extras?['currentTrackStartingPosition']);

  Duration get currentTrackLength => extras?['currentTrackLength'] == null
      ? Duration.zero
      : Duration(milliseconds: extras?['currentTrackLength']);

  Uri? get largeThumbnail => (extras?['largeThumbnail'] as String?)?.uri;
  List<Chapter> get chapters {
    if (extras != null && extras!.containsKey('chapters')) {
      return [
        for (final chapter in extras!['chapters']) Chapter.fromJson(chapter, id)
      ];
    }
    return [];
  }

  Duration get start => Duration(
        milliseconds: (extras!['start'] * 1000).round(),
      );

  Duration get end => Duration(
        milliseconds: (extras!['end'] * 1000).round(),
      );

  static MediaItem fromBook(Book book) => MediaItem(
        id: book.id,
        title: book.title,
        artist: book.author,
        album: book.title,
        artUri: Uri.parse(book.artPath),
        displayDescription: book.description,
        playable: true,
        duration: book.duration,
        extras: <String, dynamic>{
          'narrator': book.narrator,
          'largeThumbnail': book.artPath,
          'cached': true,
          'viewOffset': book.lastPlayedPosition.inMilliseconds,
          'played': book.read,
        },
      );

  static MediaItem fromTrack(Track track, Book book) => MediaItem(
        id: track.id,
        title: track.title,
        album: book.title,
        artist: book.author,
        displayDescription: book.description,
        artUri: Uri.parse(book.artPath),
        playable: true,
        extras: <String, dynamic>{
          'narrator': book.narrator,
          'largeThumbnail': book.artPath,
          'cached': true,
          'cachePath': track.downloadPath,
        },
        duration: track.duration,
      );
}

bool nullOrEmpty(List? check) {
  return check?.isEmpty ?? true;
}
