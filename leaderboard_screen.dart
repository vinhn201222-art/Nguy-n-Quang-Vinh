import 'package:flutter/material.dart';
import 'models/leaderboard_manager.dart';

class LeaderboardScreen extends StatelessWidget {
  final LeaderboardManager leaderboard;
  
  const LeaderboardScreen({required this.leaderboard, super.key});
  
  @override
  Widget build(BuildContext context) {
    final entries = leaderboard.getTop10();
    
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF001848),
              Color(0xFF000010),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        '🏆 TOP 10 SCORES',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.yellow,
                          shadows: [
                            Shadow(
                              blurRadius: 8,
                              color: Colors.black,
                              offset: Offset(2, 2),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              Expanded(
                child: entries.isEmpty
                    ? const Center(
                        child: Text(
                          'No scores yet!\nStart playing to set a record! 🎮',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 20,
                            color: Colors.white70,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        itemCount: entries.length,
                        itemBuilder: (context, index) {
                          final entry = entries[index];
                          return _buildLeaderboardItem(
                            rank: index + 1,
                            score: entry.score,
                            date: entry.date,
                          );
                        },
                      ),
              ),
              
              if (entries.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Clear Leaderboard?'),
                          content: const Text(
                            'This will delete all scores permanently.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () {
                                leaderboard.clear();
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                              child: const Text(
                                'Clear',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Clear All'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade700,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
  
  Widget _buildLeaderboardItem({
    required int rank,
    required int score,
    required DateTime date,
  }) {
    Color rankColor;
    String medal;
    if (rank == 1) {
      rankColor = const Color(0xFFFFD700);
      medal = '🥇';
    } else if (rank == 2) {
      rankColor = const Color(0xFFC0C0C0);
      medal = '🥈';
    } else if (rank == 3) {
      rankColor = const Color(0xFFCD7F32);
      medal = '🥉';
    } else {
      rankColor = Colors.white70;
      medal = '#$rank';
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: rank <= 3 ? rankColor : Colors.white30,
          width: rank <= 3 ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 50,
            child: Text(
              medal,
              style: TextStyle(
                fontSize: rank <= 3 ? 32 : 24,
                fontWeight: FontWeight.bold,
                color: rankColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  score.toString(),
                  style: TextStyle(
                    fontSize: rank <= 3 ? 28 : 24,
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 ? rankColor : Colors.white,
                    shadows: const [
                      Shadow(
                        blurRadius: 4,
                        color: Colors.black,
                        offset: Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(date),
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white60,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final month = months[date.month - 1];
    final day = date.day.toString().padLeft(2, '0');
    final year = date.year;
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '$month $day, $year - $hour:$minute';
  }
}