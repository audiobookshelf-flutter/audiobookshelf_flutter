import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/models/book.dart';
import 'package:audiobookshelf/models/chapter.dart';
import 'package:audiobookshelf/models/download_status.dart';
import 'package:audiobookshelf/models/preferences.dart';
import 'package:audiobookshelf/models/track.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final Provider<DatabaseService> databaseServiceProvider =
    Provider<DatabaseService>(((ref) => GetIt.I.get()));

abstract class DatabaseService {
  DatabaseService();

  Preferences getPreferences();
  Future insertPreferences(Preferences prefs);

  Stream<List<Book>> getBooks();
  Future<Book?> getBookById(String id);
  Stream<Book?> watchBookById(String id);
  Future insertBook(Book book);
  Future deleteBook(Book book);

  Stream<List<Track>> getTracks();
  Future<int> deleteTracks(List<Track> tracks);
  Future<Track?> getTrack(String id);
  Future updateTrackDownloadProgress(
      String taskId, double progress, bool completed);
  Stream<List<Track>> getTracksForBookId(String bookId);
  Future<Track?> getTrackByDownloadTask(String taskId);
  Future insertTrack(Track track);
  Future insertTracks(List<Track> tracks);

  Future insertChapter(Chapter chapter);
  Future insertChapters(List<Chapter> chapters);
  Future deleteChapters(List<Chapter> chapters);
  Future<List<Chapter>> getChaptersForBook(String bookId);

  Track getTrackFromMediaItem(
    MediaItem chapter,
    String bookId,
    double progress,
    String path, [
    String downloadTaskId = '',
  ]);

  Book getBookFromMediaItem(
    MediaItem book,
    DownloadStatus downloadStatus,
  );
}
