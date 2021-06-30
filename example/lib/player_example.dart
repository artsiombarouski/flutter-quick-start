import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_position.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_service.dart';
import 'package:flutter_quick_start/services/audio_player/audio_player_state.dart';
import 'package:flutter_quick_start/services/audio_player/audio_track.dart';
import 'package:flutter_quick_start/services/audio_player/widgets/audio_player_wrappers.dart';
import 'package:flutter_quick_start/services/audio_player/widgets/seek_bar.dart';
import 'package:flutter_quick_start_example/main.dart';

class MediaLibrary {
  final _items = <AudioTrack>[
    AudioTrack(
      // This can be any unique id, but we use the audio URL for convenience.
      id: "https://s3.amazonaws.com/scifri-episodes/scifri20181123-episode.mp3",
      uri: "https://waves-cms.s3.amazonaws.com/chapter1_7a0d5b7397.mp3",
      album: "Science Friday",
      title: "A Salute To Head-Scratching Science",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 5739820),
      artUri: Uri.parse(
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg")
          .toString(),
    ),
    AudioTrack(
      id: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
      uri: "https://s3.amazonaws.com/scifri-segments/scifri201711241.mp3",
      album: "Science Friday",
      title: "From Cat Rheology To Operatic Incompetence",
      artist: "Science Friday and WNYC Studios",
      duration: Duration(milliseconds: 2856950),
      artUri: Uri.parse(
              "https://media.wnyc.org/i/1400/1400/l/80/1/ScienceFriday_WNYCStudios_1400.jpg")
          .toString(),
    ),
  ];

  List<AudioTrack> get items => _items;
}

class PlayerExample extends StatefulWidget {
  const PlayerExample({Key? key}) : super(key: key);

  @override
  _PlayerExampleState createState() => _PlayerExampleState();
}

class _PlayerExampleState extends State<PlayerExample> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          TextButton(
            onPressed: () {
              AudioPlayerService.instance
                  .setQueue(MediaLibrary().items)
                  .then((value) => audioService.play());
            },
            child: Text("Set queue"),
          ),
          QsAudioStateWidget(
            builder:
                (BuildContext context, AudioPlayerState value, Widget? child) {
              return Text("state: $value");
            },
          ),
          QsAudioStateWidget(
            builder: (context, state, child) {
              bool isPlaying = state == AudioPlayerState.Playing ||
                  state == AudioPlayerState.Paused;
              return IgnorePointer(
                ignoring: !isPlaying,
                child: Opacity(
                  opacity: isPlaying ? 1.0 : 0.3,
                  child: TextButton.icon(
                    onPressed: () {
                      audioService.toggle();
                    },
                    icon: Icon(state == AudioPlayerState.Playing
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded),
                    label: Text("$state"),
                  ),
                ),
              );
            },
          ),
          QsAudioTrackWidget(
            builder: (context, value, child) {
              return Text("${value?.title ?? '---'}");
            },
          ),
          QsAudioPositionWidget(
            builder: (BuildContext context, AudioPlayerPosition? value,
                Widget? child) {
              if (value == null || value.isReady == false) {
                return Container();
              }
              return SeekBar(
                duration: value.duration!,
                position: value.position,
                bufferedPosition: value.bufferedPosition,
                onChangeEnd: audioService.seekTo,
              );
            },
          ),
          QsAudioQueueWidget(
            builder: (context, value, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (value != null)
                    ...value.map(
                      (e) => InkWell(
                        onTap: () {
                          audioService.changeByTrack(e);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          constraints: BoxConstraints(minHeight: 48),
                          child: Row(
                            children: [
                              Text("${e.title}"),
                              Text("${e.album}"),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
