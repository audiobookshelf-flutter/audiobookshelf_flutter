import 'dart:async';
import 'dart:io';

import 'package:audiobookshelf/models/download_status.dart';
import 'package:audiobookshelf/models/track.dart';
import 'package:audiobookshelf/services/database/database_service.dart';
import 'package:audiobookshelf/services/download/downloader.dart';
import 'package:audiobookshelf/utils/utils.dart';
import 'package:path/path.dart' as p;

class DesktopDownloader extends Downloader {
  DesktopDownloader(DatabaseService db) : super(db);

  @override
  Future downloadFile(
    Track track,
    Uri url,
    String path, [
    String? fileName,
  ]) async {
    late StreamSubscription sub;
    Completer completer = Completer();
    print(url);
    try {
      HttpClient client = HttpClient();
      HttpClientRequest request = await client.getUrl(url);
      request.headers.set('Accept', '*/*');
      request.headers.set('Connection', 'keep-alive');
      request.headers.set(HttpHeaders.rangeHeader, 'bytes=0');
      track = track.copyWith(downloadTaskId: track.id);

      HttpClientResponse response = await request.close();
      final total = response.headers.contentLength;
      try {
        fileName ??= RegExp(r'(["])(?:(?=(\\?))\2.)*?\1')
            .firstMatch(response.headers.value('content-disposition')!)!
            .group(0)!
            .replaceAll(RegExp(r'"'), '');
      } catch (e, stack) {
        fileName ??= track.id;
      }
      final downloadPath = p.join(
        (await Utils.getBasePath())!.path,
        path,
        fileName,
      );
      final file = File(downloadPath);
      await file.create(recursive: true);

      int saved = 0;
      double debouncer = 0;
      final fileSink = await file.open(mode: FileMode.writeOnlyAppend);
      sub = response.asBroadcastStream().listen((data) async {
        sub.pause();
        await fileSink.writeFrom(data);
        final currentProgress = saved + data.length;
        final currentPercentage = currentProgress / total;
        saved = currentProgress;
        if (currentPercentage - debouncer > 0.01) {
          await db.insertTrack(track.copyWith(
            downloadProgress: currentPercentage,
            downloadTaskId: track.id,
          ));
          debouncer = currentPercentage;
        }
        sub.resume();
      }, onDone: () async {
        await fileSink.close();
        await db.insertTrack(
          track.copyWith(
            downloadProgress: 1,
            downloadPath: p.join(path, fileName),
            isDownloaded: true,
          ),
        );
        completer.complete();
      });
    } catch (e, stack) {
      completer.completeError(e, stack);
      print(e.toString());
      print(stack.toString());
    }
    return completer.future;
  }

  @override
  Future cancelDownloads(String parentId) async {}

  @override
  Future whenAllDone(String parentId) async {
    final completer = Completer();
    StreamSubscription? trackSub;
    trackSub = db
        .getTracksForBookId(parentId)
        .where((tracks) => tracks.every((track) => track.isDownloaded))
        .listen((tracks) async {
      trackSub?.cancel();
      print('ALL DONE');

      final book = await db.getBookById(parentId);
      if (book != null) {
        await db.insertBook(
          book.copyWith(
            downloadStatus: DownloadStatus.succeeded,
          ),
        );
        completer.complete();
      }
    });
    return completer.future;
  }
}
