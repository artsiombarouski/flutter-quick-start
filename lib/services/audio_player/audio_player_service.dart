import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_position.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_provider.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_state.dart';
import 'package:flutter_quick_start/services/audio_player/audio_track.dart';

class AudioPlayerService {
  static late AudioPlayerService instance;

  final ValueNotifier<List<AudioTrack>?> currentQueue = ValueNotifier(null);
  final ValueNotifier<AudioTrack?> currentTrack = ValueNotifier(null);
  final ValueNotifier<AudioPlayerState> currentState = ValueNotifier(
    AudioPlayerState.Idle,
  );
  final ValueNotifier<AudioPlayerPosition?> currentPosition = ValueNotifier(
    null,
  );

  final AudioPlayerProvider provider;

  AudioPlayerService({required this.provider});

  Future<void> init({bool singleton = true}) async {
    currentTrack.value = provider.currentTrackStream.valueOrNull;
    provider.currentTrackStream.listen((value) {
      currentTrack.value = value;
    });
    currentQueue.value = provider.currentQueueStream.valueOrNull;
    provider.currentQueueStream.listen((value) {
      currentQueue.value = value;
    });
    currentState.value = provider.currentStateStream.value;
    provider.currentStateStream.listen((value) {
      currentState.value = value;
    });
    currentPosition.value = provider.currentPositionStream.valueOrNull;
    provider.currentPositionStream.listen((value) {
      currentPosition.value = value;
    });
    if (singleton) {
      instance = this;
    }
  }

  Future<void> setQueue(
    List<AudioTrack> tracks, {
    bool start = true,
    String? initialTrackId,
  }) async {
    await provider.init();
    await provider.doSetQueue(tracks);
    if (initialTrackId != null) {
      await changeByTrackId(initialTrackId);
    }
    if (start) {
      await play();
    }
  }

  Future<void> play() async {
    await provider.doPlay();
  }

  Future<void> pause() async {
    await provider.doPause();
  }

  Future<void> toggle() async {
    if (currentState.value == AudioPlayerState.Playing) {
      await provider.doPause();
    } else if (currentState.value == AudioPlayerState.Paused) {
      await provider.doPlay();
    } else if (currentState.value == AudioPlayerState.Completed) {
      if (currentTrack.value != null) {
        await provider.doChangeById(currentTrack.value!.id);
      }
    }
  }

  Future<void> seekTo(Duration position) async {
    await provider.doSeekTo(position);
  }

  Future<void> fastForward(Duration time) async {
    await provider.doFastForward(time);
  }

  Future<void> rewind(Duration time) async {
    await provider.doRewind(time);
  }

  Future<void> changeByTrack(AudioTrack track) async {
    await changeByTrackId(track.id);
  }

  Future<void> changeByTrackId(String id) async {
    await provider.doChangeById(id);
  }

  Future<void> stop() async {
    await provider.doStop();
  }
}
