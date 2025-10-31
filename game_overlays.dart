import 'package:flutter/material.dart';
import '../models/score.dart';
import 'game_controller.dart';
import '../leaderboard_screen.dart';

Widget buildScoreDisplay(Score score) {
  return SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _shadowText("Score: ${score.current}"),
          _shadowText("Best: ${score.best}"),
        ],
      ),
    ),
  );
}

Widget _shadowText(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2))],
      ),
    );

Widget buildMenuOverlay(GameController c) {
  if (!c.isMenu) return const SizedBox.shrink();
  
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Tap to Start",
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 8, color: Colors.black, offset: Offset(3, 3))],
          ),
        ),
        const SizedBox(height: 30),
        ElevatedButton.icon(
          onPressed: () {
            if (c.contextRef != null) {
              Navigator.push(
                c.contextRef!,
                MaterialPageRoute(
                  builder: (context) => LeaderboardScreen(leaderboard: c.leaderboard),
                ),
              );
            }
          },
          icon: const Icon(Icons.emoji_events, size: 28),
          label: const Text('Leaderboard', style: TextStyle(fontSize: 20)),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
            backgroundColor: Colors.amber.shade700,
          ),
        ),
      ],
    ),
  );
}

Widget buildGameOverOverlay(GameController c) {
  if (!c.isGameOver) return const SizedBox.shrink();
  
  final isTopScore = c.leaderboard.isTopScore(c.score.current);
  
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Game Over",
          style: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.redAccent,
            shadows: [Shadow(blurRadius: 8, color: Colors.black, offset: Offset(3, 3))],
          ),
        ),
        const SizedBox(height: 20),
        
        Text(
          "Score: ${c.score.current}",
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2))],
          ),
        ),
        
        if (isTopScore && c.score.current > 0)
          const Padding(
            padding: EdgeInsets.only(top: 10),
            child: Text(
              "🏆 New Top Score! 🏆",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.yellow,
                shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2, 2))],
              ),
            ),
          ),
        
        const SizedBox(height: 30),
        
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () => c.resetGame(),
              icon: const Icon(Icons.refresh),
              label: const Text("Restart", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              ),
            ),
            const SizedBox(width: 15),
            ElevatedButton.icon(
              onPressed: () {
                if (c.contextRef != null) {
                  Navigator.push(
                    c.contextRef!,
                    MaterialPageRoute(
                      builder: (context) => LeaderboardScreen(leaderboard: c.leaderboard),
                    ),
                  );
                }
              },
              icon: const Icon(Icons.emoji_events),
              label: const Text("Leaderboard", style: TextStyle(fontSize: 18)),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                backgroundColor: Colors.amber.shade700,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}