import 'package:freezed_annotation/freezed_annotation.dart';

part 'preferences.freezed.dart';

@freezed
class Preferences with _$Preferences {
  const factory Preferences({
    required String userToken,
    required String userId,
    required String username,
    required String libraryId,
    required String serverId,
    required double playbackSpeed,
    required double rewindInterval,
    required double fastForwardInterval,
    required String baseUrl,
    required bool useChapterProgressBar,
  }) = _Preferences;
}
