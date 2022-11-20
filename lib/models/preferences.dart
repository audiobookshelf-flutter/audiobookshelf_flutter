enum ServerType { audiobookshelf, unknown }

class Preferences {
  String userToken;
  String userId;
  String username;
  String libraryId;
  String serverId;
  double playbackSpeed;
  double rewindInterval;
  double fastForwardInterval;
  String baseUrl;
  bool useChapterProgressBar;

  Preferences({
    this.userToken = '',
    this.userId = '',
    this.username = '',
    this.libraryId = '',
    this.serverId = '',
    this.playbackSpeed = 1,
    this.rewindInterval = 15,
    this.fastForwardInterval = 30,
    this.baseUrl = '',
    this.useChapterProgressBar = false,
  });

  @override
  String toString() {
    return 'Preferences($userToken, $userId, $playbackSpeed)';
  }
}
