import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class PlayYoutubeVideo extends StatefulWidget {
  final String link;
  String videoId = '';

  PlayYoutubeVideo({super.key, required this.link}){
    videoId = YoutubePlayer.convertUrlToId(link)!;
  }

  @override
  State<PlayYoutubeVideo> createState() => _PlayYoutubeVideoState();
}

class _PlayYoutubeVideoState extends State<PlayYoutubeVideo> {

  bool isMute = true;

  late final YoutubePlayerController controller = YoutubePlayerController(
    initialVideoId: widget.videoId,
    flags: YoutubePlayerFlags(
      mute: isMute,
      autoPlay: true,
      disableDragSeek: false,
      loop: true,
      isLive: false,
      forceHD: false,
      enableCaption: true,
    ),
  );

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        // The player forces portraitUp after exiting fullscreen. This overrides the behaviour.
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.red,
        progressColors: const ProgressBarColors(
          playedColor: Colors.red,
          handleColor: Colors.grey,
        ),
        topActions: <Widget>[

          const Expanded(child: SizedBox()),

          IconButton(
            icon: Icon(
              isMute ? MingCute.volume_mute_fill : MingCute.volume_fill,
              color: Colors.white,
              size: 25.0,
            ),
            onPressed: () {

              setState(() {
                isMute = !isMute;
                if(isMute){
                  controller.mute();
                }else{
                  controller.unMute();
                }
              });

            },
          ),
        ],
        bottomActions: [
          CurrentPosition(),
          ProgressBar(
            isExpanded: true,
            colors: const ProgressBarColors(
              playedColor: Colors.red,
              handleColor: Colors.grey,
            ),
          ),
          RemainingDuration(),
          const PlaybackSpeedButton(),
          FullScreenButton(),
          //TotalDuration(),
        ],
        onReady: () {
          /*final blocProvider = BlocProvider.of<YoutubePlayerBloc>(context);
            blocProvider.add(VideoPlayerReadyEvent());*/
        },
      ),
      builder: (context, player) => player,
    );
  }
}