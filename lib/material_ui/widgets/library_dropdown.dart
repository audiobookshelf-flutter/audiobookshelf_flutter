import 'package:audiobookshelf/domain/library_select/library_select_notifier.dart';
import 'package:audiobookshelf/models/library.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class LibraryDropdown extends HookConsumerWidget {
  const LibraryDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final libraryProvider = ref.watch(libraryStateProvider.notifier);

    return Consumer(builder: (context, ref, child) {
      final state = ref.watch(libraryStateProvider);
      return state.maybeMap(
        orElse: () => const Text("Error"),
        loaded: (s) {
          return DropdownButton<Library>(
            value: s.libraries?.first,
            onChanged: (Library? value) {
              libraryProvider.setLibrary(value!.id!);
            },
            items: s.libraries?.map<DropdownMenuItem<Library>>((Library value) {
              return DropdownMenuItem<Library>(
                value: value,
                child: Text(value.title!),
              );
            }).toList(),
          );
        },
      );
    });
  }
}