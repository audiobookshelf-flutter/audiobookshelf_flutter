import 'dart:io';

import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/constants/app_constants.dart';
import 'package:audiobookshelf/domain/offline/offline_notifier.dart';
import 'package:audiobookshelf/domain/offline/offline_state.dart';
import 'package:audiobookshelf/ui/features/player/mini_player.dart';
import 'package:audiobookshelf/services/audio/playback_controller.dart';
import 'package:audiobookshelf/services/navigation/navigation_service.dart';
import 'package:audiobookshelf/ui/widgets/book_grid_item.dart';
import 'package:audiobookshelf/ui/widgets/responsive_grid_view.dart';
import 'package:audiobookshelf/ui/widgets/scaffold_without_footer.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audiobookshelf/utils/utils.dart';
import 'package:loggy/loggy.dart';

class Offline extends HookConsumerWidget {
  const Offline({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<RefreshIndicatorState> refresher =
        GlobalKey<RefreshIndicatorState>();

    final offlineProvider = ref.watch(offlineStateProvider.notifier);
    final playbackController = GetIt.I<PlaybackController>();
    final navigationService = ref.watch(navigationServiceProvider);

    return ScaffoldWithoutFooter(
      refresh: !kIsWeb && !Platform.isAndroid && !Platform.isIOS,
      onRefresh: () {
        refresher.currentState!.show();
      },
      title: const Text('Library'),
      body: RefreshIndicator(
        key: refresher,
        onRefresh: () async {
          logDebug('refreshing');
          return offlineProvider.getBooks();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final state = ref.watch(offlineStateProvider);
                  if (state is OfflineStateInitial) {
                    refresher.currentState!.show();
                  }
                  if (state is OfflineStateLoaded) {
                    // if (state.currentParent != mediaId)
                    // _refresher.currentState!.show();
                    return ResponsiveGridView<MediaItem>(
                      items: state.books,
                      itemBuilder: (book) {
                        return BookGridItem(
                          onTap: () async {
                            Navigator.of(context)
                                .pushNamed(Routes.book, arguments: book.id);
                            // playbackController.playFromId(book.id);
                            // navigationService.pushNamed(
                            //   Routes.Player,
                            //   arguments: book,
                            // );
                          },
                          thumbnailUrl: book.artUri?.toString(),
                          title: book.title,
                          subtitle: book.artist,
                          progress: Utils.getProgress(item: book),
                          played: book.played,
                        );
                      },
                    );
                  } else if (state is OfflineStateErrorDetails) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(state.message!),
                          ElevatedButton(
                            onPressed: refresher.currentState!.show,
                            child: const Text('Retry'),
                          )
                        ],
                      ),
                    );
                  } else {
                    return Container();
                  }
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: MiniPlayer(),
            ),
          ],
        ),
      ),
    );
  }
}
