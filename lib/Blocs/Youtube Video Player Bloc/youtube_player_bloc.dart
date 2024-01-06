import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:superstate/Blocs/Youtube%20Video%20Player%20Bloc/youtube_player_events.dart';
import 'package:superstate/Blocs/Youtube%20Video%20Player%20Bloc/youtube_player_states.dart';

class YoutubePlayerBloc extends Bloc<YoutubePlayerEvents, YoutubePlayerStates>{
  YoutubePlayerBloc() : super(const YoutubePlayerStates(isPlayerReady: false)){
    on<YoutubePlayerEvents>((event, emit) {
      if(event is YoutubePlayerOnReadyEvent){
        emit(const YoutubePlayerStates(isPlayerReady: true));
      }
    });
  }
}