import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_position.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_provider.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_state.dart';
import 'package:flutter_quick_start/services/audio_player/audio_track.dart';
import 'package:just_audio/just_audio.dart';

void _entrypoint() async {
  AudioServiceBackground.run(() => JustAudioService());
}

class JustAudioProvider with AudioPlayerProvider, WidgetsBindingObserver {
  /// Provider impls

  StreamSubscription? _queueSubscription;
  StreamSubscription? _trackSubscription;
  StreamSubscription? _playbackSubscription;
  StreamSubscription? _positionSubscription;

  @override
  Future<void> init() async {
    if (AudioService.running) {
      return;
    }
    WidgetsFlutterBinding.ensureInitialized().addObserver(this);
    await AudioService.connect();
    await AudioService.start(backgroundTaskEntrypoint: _entrypoint);

    currentQueueStream.value =
        AudioService.queue?.map((e) => AudioTrack.fromMediaItem(e)).toList();
    _queueSubscription = AudioService.queueStream.listen((event) {
      currentQueueStream.value =
          event?.map((e) => AudioTrack.fromMediaItem(e)).toList();
    });

    currentTrackStream.value = AudioService.currentMediaItem != null
        ? AudioTrack.fromMediaItem(AudioService.currentMediaItem!)
        : null;
    _trackSubscription = AudioService.currentMediaItemStream.listen((event) {
      currentTrackStream.value =
          event != null ? AudioTrack.fromMediaItem(event) : null;
    });
    await _syncPlayerState();
    _playbackSubscription = AudioService.playbackStateStream.listen((event) {
      _syncPlayerState();
    });
    _positionSubscription = AudioService.positionStream.listen((event) {
      _syncPlayerState();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        AudioService.connect();
        break;
      case AppLifecycleState.paused:
        AudioService.disconnect();
        break;
      default:
        break;
    }
  }

  @override
  Future<void> dispose() async {
    await super.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    _queueSubscription?.cancel();
    _trackSubscription?.cancel();
    _playbackSubscription?.cancel();
    _positionSubscription?.cancel();
  }

  Future<void> _syncPlayerState() async {
    final playbackState = AudioService.playbackState;
    final processingState = playbackState.processingState;
    late AudioPlayerState currentState;
    switch (processingState) {
      case AudioProcessingState.none:
        currentState = AudioPlayerState.Idle;
        break;
      case AudioProcessingState.error:
      case AudioProcessingState.stopped:
        currentState = AudioPlayerState.Stopped;
        break;
      case AudioProcessingState.connecting:
      case AudioProcessingState.skippingToPrevious:
      case AudioProcessingState.skippingToNext:
      case AudioProcessingState.skippingToQueueItem:
        currentState = AudioPlayerState.Loading;
        break;
      case AudioProcessingState.fastForwarding:
      case AudioProcessingState.rewinding:
        currentState = AudioPlayerState.Buffering;
        break;
      case AudioProcessingState.buffering:
        currentState = playbackState.playing ||
                playbackState.position < playbackState.bufferedPosition
            ? AudioPlayerState.Playing
            : AudioPlayerState.Buffering;
        break;
      case AudioProcessingState.ready:
        currentState = playbackState.playing
            ? AudioPlayerState.Playing
            : AudioPlayerState.Paused;
        break;
      case AudioProcessingState.completed:
        currentState = AudioPlayerState.Completed;
        break;
    }
    currentStateStream.value = currentState;
    currentPositionStream.value = AudioPlayerPosition(
      duration: currentTrackStream.value?.duration,
      bufferedPosition: playbackState.bufferedPosition,
      position: playbackState.currentPosition,
    );
  }

  @override
  Future<void> doSetQueue(List<AudioTrack> tracks) async {
    await AudioService.updateQueue(tracks.map((e) => e.toMediaItem()).toList());
  }

  @override
  Future<void> doChangeById(String trackId) async {
    if (kIsWeb) {
      await AudioService.customAction("customSkipToQueueItem", [trackId]);
    } else {
      await AudioService.skipToQueueItem(trackId);
    }
  }

  @override
  Future<void> doPlay() async {
    await AudioService.play();
  }

  @override
  Future<void> doPause() async {
    await AudioService.pause();
  }

  @override
  Future<void> doFastForward(Duration time) async {
    await AudioService.seekTo(time);
  }

  @override
  Future<void> doRewind(Duration rewind) async {
    await AudioService.seekTo(-rewind);
  }

  @override
  Future<void> doSeekTo(Duration position) async {
    await AudioService.seekTo(position);
  }

  @override
  Future<void> doStop() async {
    await AudioService.stop();
  }
}

class JustAudioService extends BackgroundAudioTask {
  AudioPlayer _player = new AudioPlayer();
  AudioProcessingState? _skipState;
  Seeker? _seeker;
  late StreamSubscription<PlaybackEvent> _eventSubscription;

  List<MediaItem> queue = [];

  int? get index => _player.currentIndex;

  MediaItem? get mediaItem => index == null ? null : queue[index!];

  @override
  Future<void> onStart(Map<String, dynamic>? params) async {
    // We configure the audio session for speech since we're playing a podcast.
    // You can also put this in your app's initialisation if your app doesn't
    // switch between two types of audio as this example does.
    final session = await AudioSession.instance;
    await session.configure(AudioSessionConfiguration.music());
    // Broadcast media item changes.
    _player.currentIndexStream.listen((index) {
      if (index != null && queue.isNotEmpty) {
        AudioServiceBackground.setMediaItem(queue[index]);
      }
    });
    _player.sequenceStateStream.listen((event) {
      if (event != null && queue.isNotEmpty) {
        AudioServiceBackground.setMediaItem(queue[index!]);
      }
    });
    // Propagate all events from the audio player to AudioService clients.
    _eventSubscription = _player.playbackEventStream.listen((event) {
      _broadcastState();
    });
    // Special processing for state transitions.
    _player.processingStateStream.listen((state) {
      switch (state) {
        case ProcessingState.completed:
          // In this example, the service stops when reaching the end.
          onStop();
          break;
        case ProcessingState.ready:
          // If we just came from skipping between tracks, clear the skip
          // state now that we're ready to play.
          _skipState = null;
          break;
        default:
          break;
      }
    });
  }

  @override
  Future<void> onUpdateQueue(List<MediaItem> queue) async {
    this.queue.clear();
    this.queue.addAll(queue);

    //Cancel current processing
    await _player.stop();

    // Load and broadcast the queue
    AudioServiceBackground.setQueue(queue);
    try {
      await _player.setAudioSource(ConcatenatingAudioSource(
        children:
            queue.map((item) => AudioSource.uri(Uri.parse(item.id))).toList(),
      ));
      // In this example, we automatically start playing on start.
      // onPlay();
    } catch (e) {
      print("Error: $e");
      onStop();
    }
  }

  @override
  Future<void> onSkipToQueueItem(String mediaId) async {
    // Then default implementations of onSkipToNext and onSkipToPrevious will
    // delegate to this method.
    final newIndex = queue.indexWhere((item) => item.id == mediaId);
    if (newIndex == -1) return;
    // During a skip, the player may enter the buffering state. We could just
    // propagate that state directly to AudioService clients but AudioService
    // has some more specific states we could use for skipping to next and
    // previous. This variable holds the preferred state to send instead of
    // buffering during a skip, and it is cleared as soon as the player exits
    // buffering (see the listener in onStart).
    _skipState = newIndex > index!
        ? AudioProcessingState.skippingToNext
        : AudioProcessingState.skippingToPrevious;
    // This jumps to the beginning of the queue item at newIndex.
    _player.seek(Duration.zero, index: newIndex);
  }

  @override
  Future<void> onCustomAction(String name, arguments) async {
    if (name == 'customSkipToQueueItem') {
      await onSkipToQueueItem(arguments[0]);
    }
  }

  @override
  Future<void> onPlay() => _player.play();

  @override
  Future<void> onPause() => _player.pause();

  @override
  Future<void> onSeekTo(Duration position) => _player.seek(position);

  @override
  Future<void> onFastForward() => seekRelative(fastForwardInterval);

  @override
  Future<void> onRewind() => seekRelative(-rewindInterval);

  @override
  Future<void> onSeekForward(bool begin) async => _seekContinuously(begin, 1);

  @override
  Future<void> onSeekBackward(bool begin) async => _seekContinuously(begin, -1);

  @override
  Future<void> onStop() async {
    await _player.dispose();
    _eventSubscription.cancel();
    // It is important to wait for this state to be broadcast before we shut
    // down the task. If we don't, the background task will be destroyed before
    // the message gets sent to the UI.
    await _broadcastState();
    // Shut down this task
    await super.onStop();
  }

  /// Jumps away from the current position by [offset].
  Future<void> seekRelative(Duration offset) async {
    var newPosition = _player.position + offset;
    // Make sure we don't jump out of bounds.
    if (newPosition < Duration.zero) newPosition = Duration.zero;
    if (newPosition > mediaItem!.duration!) newPosition = mediaItem!.duration!;
    // Perform the jump via a seek.
    await _player.seek(newPosition);
  }

  /// Begins or stops a continuous seek in [direction]. After it begins it will
  /// continue seeking forward or backward by 10 seconds within the audio, at
  /// intervals of 1 second in app time.
  void _seekContinuously(bool begin, int direction) {
    _seeker?.stop();
    if (begin) {
      _seeker = Seeker(_player, Duration(seconds: 10 * direction),
          Duration(seconds: 1), mediaItem!)
        ..start();
    }
  }

  /// Broadcasts the current state to all clients.
  Future<void> _broadcastState() async {
    await AudioServiceBackground.setState(
      controls: [
        MediaControl.skipToPrevious,
        if (_player.playing) MediaControl.pause else MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      systemActions: [
        MediaAction.seekTo,
        MediaAction.seekForward,
        MediaAction.seekBackward,
      ],
      androidCompactActions: [0, 1, 3],
      processingState: _getProcessingState(),
      playing: _player.playing,
      position: _player.position,
      bufferedPosition: _player.bufferedPosition,
      speed: _player.speed,
    );
  }

  /// Maps just_audio's processing state into into audio_service's playing
  /// state. If we are in the middle of a skip, we use [_skipState] instead.
  AudioProcessingState _getProcessingState() {
    if (_skipState != null) return _skipState!;
    switch (_player.processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.none;
      case ProcessingState.loading:
        return AudioProcessingState.connecting;
      case ProcessingState.buffering:
        if (_player.position < _player.bufferedPosition)
          return AudioProcessingState.ready;
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        throw Exception("Invalid state: ${_player.processingState}");
    }
  }
}

class Seeker {
  final AudioPlayer player;
  final Duration positionInterval;
  final Duration stepInterval;
  final MediaItem mediaItem;
  bool _running = false;

  Seeker(
    this.player,
    this.positionInterval,
    this.stepInterval,
    this.mediaItem,
  );

  start() async {
    _running = true;
    while (_running) {
      Duration newPosition = player.position + positionInterval;
      if (newPosition < Duration.zero) newPosition = Duration.zero;
      if (newPosition > mediaItem.duration!) newPosition = mediaItem.duration!;
      player.seek(newPosition);
      await Future.delayed(stepInterval);
    }
  }

  stop() {
    _running = false;
  }
}
