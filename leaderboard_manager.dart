import 'dart:convert';

class LeaderboardEntry {
  final int score;
  final DateTime date;
  
  LeaderboardEntry({required this.score, required this.date});
  
  Map<String, dynamic> toJson() => {
    'score': score,
    'date': date.toIso8601String(),
  };
  
  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntry(
      score: json['score'] as int,
      date: DateTime.parse(json['date'] as String),
    );
  }
}

class LeaderboardManager {
  List<LeaderboardEntry> entries = [];
  
  void addScore(int score) {
    if (score <= 0) return;
    
    entries.add(LeaderboardEntry(
      score: score,
      date: DateTime.now(),
    ));
    
    entries.sort((a, b) => b.score.compareTo(a.score));
    
    if (entries.length > 10) {
      entries = entries.sublist(0, 10);
    }
    
    _saveToStorage();
  }
  
  List<LeaderboardEntry> getTop10() {
    return entries.take(10).toList();
  }
  
  bool isTopScore(int score) {
    if (entries.length < 10) return true;
    return score > entries.last.score;
  }
  
  Future<void> _saveToStorage() async {
    try {
      final data = entries.map((e) => e.toJson()).toList();
      final jsonString = jsonEncode(data);
    } catch (e) {
      print('Error saving leaderboard: $e');
    }
  }
  
  Future<void> loadFromStorage() async {
    try {
    } catch (e) {
      print('Error loading leaderboard: $e');
    }
  }
  
  void clear() {
    entries.clear();
    _saveToStorage();
  }
}