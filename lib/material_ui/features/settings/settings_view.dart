import 'package:audiobookshelf/domain/auth/auth_notifier.dart';
import 'package:audiobookshelf/domain/settings/settings_notifier.dart';
import 'package:audiobookshelf/domain/settings/settings_state.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsView extends HookConsumerWidget {
  const SettingsView({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(context, ref) {
    final state = ref.watch(settingsStateProvider);
    final auth = ref.watch(authNotifierProvider.notifier);
    // if (state is SettingsStateInitial) Future.value(settings.getUser());
    if (state is SettingsStateLoaded) {
      return ListView(
        children: [
          ListTile(
            title: const Text('About Audiobookshelf'),
            onTap: () {
              showAboutDialog(
                context: context,
                applicationName: 'Audiobookshelf',
                applicationVersion: '0.1.0',
                applicationIcon: Image.asset(
                  'assets/audiobookshelf_icon.png',
                  height: 50.0,
                ),
                useRootNavigator: true,
              );
            },
          ),
          ListTile(
            title: const Text('Account'),
            subtitle: Text(state.user!.userName!),
            trailing: state.user!.thumb != null
                ? Image.network(
                    state.user!.thumb!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, exception, stackTrace) {
                      return Container();
                    },
                  )
                : const Icon(Icons.person),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              child: const Text('Logout'),
              onPressed: () async {
                await auth.logout();
              },
            ),
          )
        ],
      );
    } else {
      return const Center(child: CircularProgressIndicator());
    }
  }
}
