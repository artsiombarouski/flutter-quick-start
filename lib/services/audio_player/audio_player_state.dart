enum AudioPlayerState {
  /// The player has not loaded.
  Idle,

  /// The player has stopped (e.g - manual or updating queue).
  Stopped,

  /// The player is loading.
  Loading,

  /// The player is buffering audio and unable to play.
  Buffering,

  /// The player is playing
  Playing,

  /// The player is paused
  Paused,

  /// The player has reached the end of the audio.
  Completed,
}
