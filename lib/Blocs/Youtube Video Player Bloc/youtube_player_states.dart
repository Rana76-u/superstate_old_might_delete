import 'package:equatable/equatable.dart';

class YoutubePlayerStates extends Equatable {
  final bool isPlayerReady;

  const YoutubePlayerStates({required this.isPlayerReady});

  @override
  List<Object?> get props => [isPlayerReady];
}