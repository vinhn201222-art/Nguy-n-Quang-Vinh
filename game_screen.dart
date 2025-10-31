import 'package:flutter/material.dart';
import 'game_core/game_controller.dart';
import 'game_core/game_overlays.dart';
import 'game_core/game_buttons.dart';

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  late GameController _controller;

  @override
  void initState() {
    super.initState();
    _controller = GameController(vsync: this, onUpdate: () => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _controller.updateScreenSize(MediaQuery.of(context).size);

    return Scaffold(
      body: Stack(
        children: [
          // Vẽ khung game
          _controller.buildGameCanvas(onTap: () {
            if (_controller.isMenu) _controller.startNewGame(context);
          }),

          // Hiển thị điểm
          buildScoreDisplay(_controller.score),

          // Menu khi tạm dừng
          buildMenuOverlay(_controller),

          // Màn hình khi thua
          buildGameOverOverlay(_controller),

          // 👇 Cụm 2 nút điều khiển ảo - ĐÃ SỬA LAYOUT
          GameButtonsOverlay(
            visible: _controller.isPlaying,
            onLeftDown: () => _controller.leftPressed = true,
            onLeftUp: () => _controller.leftPressed = false,
            onRightDown: () => _controller.rightPressed = true,
            onRightUp: () => _controller.rightPressed = false,
          ),
        ],
      ),
    );
  }
}