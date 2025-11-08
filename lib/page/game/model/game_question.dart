import 'package:town_pass/page/game/model/attraction.dart';

class GameQuestion {
  const GameQuestion({
    required this.target,
    required this.options,
    required this.correctIndex,
  });

  final Attraction target;
  final List<GameOption> options;
  final int correctIndex;
}

class GameOption {
  const GameOption({
    required this.attraction,
    required this.distanceScore,
  });

  final Attraction attraction;
  final double distanceScore;
}
