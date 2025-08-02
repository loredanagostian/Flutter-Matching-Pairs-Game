class ScoreEntry {
  final int score;
  final int time;
  final int moves;

  ScoreEntry({required this.score, required this.time, required this.moves});

  Map<String, dynamic> toJson() => {
    'score': score,
    'time': time,
    'moves': moves,
  };

  factory ScoreEntry.fromJson(Map<String, dynamic> json) => ScoreEntry(
    score: json['score'],
    time: json['time'],
    moves: json['moves'],
  );
}
