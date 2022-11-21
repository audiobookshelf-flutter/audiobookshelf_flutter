import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/models/library.dart';
import 'package:audiobookshelf/models/user.dart';
import 'package:loggy/loggy.dart';

enum AudiobookshelfPlaybackState {
  playing,
  paused,
  stopped,
  completed,
  buffering,
}

enum AudiobookshelfEvent {
  timeUpdate,
  pause,
  unpause,
  playbackRateChange,
  stop
}

abstract class MediaRepository {
  MediaRepository([this.enableSeries = false]);
  final bool enableSeries;

  Future<List<MediaItem>> getChildren(String parentMediaId) async {
    var pieces = parentMediaId.split('/');
    logDebug('Parent media id! $parentMediaId');
    switch (pieces[0]) {
      case AudioService.browsableRootId:
        var items = <MediaItem>[
          const MediaItem(
            id: MediaIds.downloads,
            title: 'Downloads',
            playable: false,
          ),
          const MediaItem(
            id: MediaIds.recentlyPlayed,
            title: 'In Progress',
            playable: false,
          ),
          const MediaItem(
            id: MediaIds.recentlyAdded,
            title: 'Recently Added',
            playable: false,
          ),
          const MediaItem(
            id: MediaIds.authorsId,
            title: 'Authors',
            playable: false,
          ),
          const MediaItem(
            id: MediaIds.booksId,
            title: 'All Books',
            playable: false,
          ),
          if (enableSeries)
            const MediaItem(
              id: MediaIds.seriesId,
              title: 'Series',
              playable: false,
            ),
          const MediaItem(
            id: MediaIds.collectionsId,
            title: 'Collections',
            playable: false,
          ),
        ];
        return await Future.value(items);
      case AudioService.recentRootId:
        return (await getRecentlyPlayed()).take(1).toList();
      case MediaIds.authorsId:
        if (pieces.length > 1) {
          return await getBooksFromAuthor(pieces[1]);
        } else {
          return getAuthors();
        }
      case MediaIds.booksId:
        return getAllBooks();
      case MediaIds.downloads:
        return getDownloads();
      case MediaIds.collectionsId:
        if (pieces.length > 1) {
          return await getBooksFromCollection(pieces[1]);
        } else {
          return await getCollections();
        }
      case MediaIds.seriesId:
        if (pieces.length > 1) {
          return await getBooksFromSeries(pieces[1]);
        } else {
          return await getSeries();
        }
      case MediaIds.recentlyPlayed:
        return await getRecentlyPlayed();
      case MediaIds.recentlyAdded:
        return await getRecentlyAdded();
      default:
        return Future.value(<MediaItem>[]);
    }
  }

  Future<List<MediaItem>> getRecentlyAdded();
  Future<List<MediaItem>> getDownloads();
  Future<List<MediaItem>> getRecentlyPlayed();
  Future<List<MediaItem>> getAllBooks();
  Future<List<MediaItem>> getAuthors();
  Future<List<MediaItem>> getBooksFromAuthor(String authorId);
  Future<List<MediaItem>> getCollections();
  Future<List<MediaItem>> getBooksFromCollection(String collectionId);
  Future<List<MediaItem>> getSeries();
  Future<List<MediaItem>> getBooksFromSeries(String seriesId);
  Future<List<MediaItem>> search(String search);
  Future<List<Library>> getLibraries();
  Future<List<MediaItem>> getTracksForBook(String bookId);
  Future<MediaItem> getAlbumFromId(String? mediaId);
  Future<User> getUser();
  Future<String> getLoginUrl();
  Future savePosition(String key, int position, int duration,
      AudiobookshelfPlaybackState state);
  Future playbackStarted(
      String key, Duration position, Duration duration, double playbackRate);
  Future playbackCheckin(String key, Duration position, Duration duration,
      double playbackRate, AudiobookshelfEvent event, bool playing);
  Future playbackStopped(
      String key, Duration position, Duration duration, double playbackRate);
  Future getServerAndLibrary();
  Future markPlayed(String itemId);
  Future markUnplayed(String itemId);
  Future addToCollection(String collectionId, String mediaId);
  String getServerUrl(String path);
  String getThumbnailUrl(
    String? path, {
    int? height,
    int? width,
  });
  Future playbackFinished(String key);
  String getDownloadUrl(String path);
  void setLibraryId(String libraryId) {}
}
