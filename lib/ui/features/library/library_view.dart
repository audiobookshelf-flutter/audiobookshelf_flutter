import 'dart:io';

import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/ui/features/book_details/book_details_view.dart';
import 'package:audiobookshelf/domain/books/books_notifier.dart';
import 'package:audiobookshelf/ui/widgets/book_grid_item.dart';
import 'package:audiobookshelf/ui/widgets/library_dropdown.dart';
import 'package:audiobookshelf/ui/widgets/responsive_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audiobookshelf/ui/widgets/scaffold_without_footer.dart';
import 'package:audiobookshelf/utils/utils.dart';

class LibraryView extends HookConsumerWidget {
  final String? mediaId;
  final String? title;

  const LibraryView({super.key, this.mediaId, this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<RefreshIndicatorState> refresher =
        GlobalKey<RefreshIndicatorState>();

    final booksProvider = ref.watch(booksStateProvider(mediaId).notifier);

    return ScaffoldWithoutFooter(
      refresh: !kIsWeb && !Platform.isAndroid && !Platform.isIOS,
      onRefresh: () {
        refresher.currentState!.show();
      },
      title: const LibraryDropdown(),
      body: RefreshIndicator(
        key: refresher,
        onRefresh: () async {
          print('refreshing');
          return booksProvider.refresh();
        },
        child: Consumer(
          builder: (context, ref, child) {
            final state = ref.watch(booksStateProvider(mediaId));
            return state.maybeWhen(
              orElse: () => Container(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (books, currentParent) {
                return ResponsiveGridView<MediaItem>(
                  items: books,
                  itemBuilder: (book) {
                    return OpenContainer(
                      closedElevation: 0,
                      useRootNavigator: false,
                      closedColor: Theme.of(context).canvasColor,
                      openColor: Theme.of(context).canvasColor,
                      openBuilder: (context, closeContainer) =>
                          BookDetailsView(mediaId: book.id),
                      closedBuilder: (context, openContainer) => BookGridItem(
                        onTap: () async {
                          openContainer();
                        },
                        thumbnailUrl: book.artUri?.toString(),
                        title: book.title,
                        subtitle: book.artist,
                        progress: Utils.getProgress(item: book),
                        played: book.played,
                        placeholder: Icons.book,
                      ),
                    );
                  },
                );
              },
              error: (message) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(message!),
                      ElevatedButton(
                        onPressed: booksProvider.refresh,
                        child: const Text('Retry'),
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
