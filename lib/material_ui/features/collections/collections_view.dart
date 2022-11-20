import 'dart:io';

import 'package:animations/animations.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audiobookshelf/material_ui/features/library/library_view.dart';
import 'package:audiobookshelf/domain/collections/collections_notifier.dart';
import 'package:audiobookshelf/material_ui/widgets/book_grid_item.dart';
import 'package:audiobookshelf/material_ui/widgets/library_dropdown.dart';
import 'package:audiobookshelf/material_ui/widgets/responsive_grid_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:audiobookshelf/material_ui/widgets/scaffold_without_footer.dart';

class CollectionsView extends HookConsumerWidget {
  const CollectionsView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final GlobalKey<RefreshIndicatorState> refresher =
        GlobalKey<RefreshIndicatorState>();

    final booksProvider = ref.watch(collectionsStateProvider.notifier);

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
            final state = ref.watch(collectionsStateProvider);
            return state.maybeWhen(
              orElse: () => Container(),
              loading: () => const Center(child: CircularProgressIndicator()),
              loaded: (collections) {
                return ResponsiveGridView<MediaItem>(
                  items: collections,
                  itemBuilder: (collection) {
                    return OpenContainer(
                      key: Key(collection.title),
                      closedElevation: 0.0,
                      closedColor: Theme.of(context).canvasColor,
                      openColor: Theme.of(context).canvasColor,
                      openBuilder: (context, closeContainer) => LibraryView(
                          mediaId: collection.id, title: collection.title),
                      closedBuilder: (context, openContainer) => BookGridItem(
                        onTap: openContainer,
                        thumbnailUrl: collection.artUri?.toString(),
                        title: collection.title,
                        placeholder: Icons.collections_bookmark,
                        showTitle: true,
                      ),
                    );
                  },
                );
              },
              error: (message) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Center(
                      child: Text(
                        'Could not fetch collections, is the device online?',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        booksProvider.refresh();
                      },
                      child: const Text('Retry'),
                    )
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
