import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/enums.dart';
import '../models/player.dart';
import '../models/platform_manager.dart';
import '../models/score.dart';
import '../models/obstacle.dart';
import '../models/vector2.dart';
import '../painters/game_painter.dart';
import '../utils/image_loader.dart';
import '../utils/sound_manager.dart'; 
import 'game_input.dart';
import 'game_updater.dart';
import '../models/leaderboard_manager.dart';

class GameController {
  final TickerProvider vsync;
  final VoidCallback onUpdate;

  late AnimationController _animController;
  Duration _lastTick = Duration.zero;

  Player? player;
  late PlatformManager platformManager;
  late Score score;
  late LeaderboardManager leaderboard;
  late SoundManager soundManager; // ← THÊM DÒNG NÀY
  GameStatus status = GameStatus.menu;
  List<Obstacle> obstacles = [];

  double cameraY = 0;
  Size screenSize = Size.zero;
  ui.Image? playerImage;

  bool leftPressed = false;
  bool rightPressed = false;

  double fallTime = 0.0;
  bool hasLandedThisFrame = false;
  BuildContext? contextRef;
  
  GameController({required this.vsync, required this.onUpdate}) {
    platformManager = PlatformManager();
    score = Score();
    leaderboard = LeaderboardManager();
    leaderboard.loadFromStorage();
    soundManager = SoundManager(); // ← THÊM DÒNG NÀY
    soundManager.init(); // ← THÊM DÒNG NÀY
    _startLoop();
    HardwareKeyboard.instance.addHandler(_handleKey);
  }

  void dispose() {
    _animController.dispose();
    HardwareKeyboard.instance.removeHandler(_handleKey);
    soundManager.dispose(); // ← THÊM DÒNG NÀY
  }

  void updateScreenSize(Size size) => screenSize = size;

  void _startLoop() {
    _animController = AnimationController(
      vsync: vsync, 
      duration: const Duration(days: 9999)
    )..addListener(() {
        final elapsed = _animController.lastElapsedDuration ?? Duration.zero;
        _onTick(elapsed);
      });
    _animController.repeat();
  }

  void startNewGame(BuildContext context) {
    contextRef = context;
    screenSize = MediaQuery.of(context).size;

    platformManager.platforms.clear();
    platformManager.seedInitial(screenSize.width, screenSize.height);

    final firstPlatform = platformManager.platforms.first;
    player = Player(
      pos: Vector2(
        firstPlatform.rect.left + firstPlatform.rect.width / 2 - 22,
        firstPlatform.rect.top - 50
      ),
      width: 44,
      height: 44,
      jumpStrength: 650,
    );

    cameraY = player!.pos.y + 300;
    score.reset();
    status = GameStatus.playing;
    _lastTick = Duration.zero;
    fallTime = 0.0;
    leftPressed = false;
    rightPressed = false;

    _loadPlayerImage();
    _createObstacles();
    
    // ← THÊM: Phát nhạc nền khi bắt đầu game
    soundManager.playBackgroundMusic();
  }

  void resetGame() {
    status = GameStatus.menu;
    player = null;
    obstacles.clear();
    platformManager.platforms.clear();
    score.reset();
    _lastTick = Duration.zero;
    fallTime = 0.0;
    hasLandedThisFrame = false;
    leftPressed = false;
    rightPressed = false;

    // ← THÊM: Dừng nhạc nền khi reset
    soundManager.stopBackgroundMusic();

    if (contextRef != null) {
      startNewGame(contextRef!);
    }
  }

  void _loadPlayerImage() async {
    try {
      playerImage = await loadImage('assets/Screenshot (2).png');
    } catch (e) {
      debugPrint('Failed to load player image: $e');
    }
  }

  void _createObstacles() {
    obstacles = [
      Obstacle(
        pos: Offset(100, player!.pos.y - 400), 
        width: 50, 
        height: 30, 
        type: ObstacleType.spike, 
        moveRange: 200, 
        moveSpeed: 80
      ),
      Obstacle(
        pos: Offset(250, player!.pos.y - 800), 
        width: 60, 
        height: 40, 
        type: ObstacleType.deadly, 
        moveRange: 150, 
        moveSpeed: 60
      ),
    ];
  }

  void ensureObstacles() {
    if (player == null) return;
    
    double highestObstacleY = obstacles.isEmpty 
        ? player!.pos.y 
        : obstacles.map((o) => o.pos.dy).reduce((a, b) => a < b ? a : b);
    
    while (highestObstacleY > cameraY - 1200) {
      final rng = platformManager.rng;
      
      double difficulty = (cameraY.abs() / 6000).clamp(0.0, 0.7);
      
      double minGap = 600 - (difficulty * 100);
      double maxGap = 900 - (difficulty * 200);
      double gap = minGap + rng.nextDouble() * (maxGap - minGap);
      double newY = highestObstacleY - gap;
      
      double x;
      if (rng.nextBool()) {
        x = rng.nextDouble() * (screenSize.width * 0.35) + 20;
      } else {
        x = screenSize.width * 0.65 + rng.nextDouble() * (screenSize.width * 0.35 - 80);
      }
      
      ObstacleType type;
      double typeRoll = rng.nextDouble();
      if (typeRoll < 0.15 + difficulty * 0.15) {
        type = ObstacleType.deadly;
      } else {
        type = ObstacleType.spike;
      }
      
      obstacles.add(Obstacle(
        pos: Offset(x, newY),
        width: 40 + rng.nextDouble() * 12,
        height: 22 + rng.nextDouble() * 10,
        type: type,
        moveRange: 70 + rng.nextDouble() * (100 + difficulty * 60),
        moveSpeed: 35 + rng.nextDouble() * (50 + difficulty * 35),
      ));
      
      highestObstacleY = newY;
    }
    
    obstacles.removeWhere((o) => o.pos.dy > cameraY + screenSize.height + 500);
  }

  bool _handleKey(KeyEvent event) {
    handleKeyboardInput(event, this);
    return false;
  }

  void _onTick(Duration elapsed) {
    double dt = 0;
    if (_lastTick != Duration.zero) {
      dt = (elapsed - _lastTick).inMilliseconds / 1000.0;
      dt = dt.clamp(0, 0.1);
    }
    _lastTick = elapsed;

    if (status == GameStatus.playing && dt > 0) {
      updateGame(this, dt);
    }

    onUpdate();
  }

  Widget buildGameCanvas({required VoidCallback onTap}) {
    return Positioned.fill(
      child: GestureDetector(
        onTap: onTap,
        child: CustomPaint(
          painter: GamePainter(
            player: player,
            platforms: platformManager.platforms,
            obstacles: obstacles,
            cameraY: cameraY,
            playerImage: playerImage,
          ),
        ),
      ),
    );
  }

  bool get isMenu => status == GameStatus.menu;
  bool get isGameOver => status == GameStatus.gameOver;
  bool get isPlaying => !isMenu && !isGameOver;
}