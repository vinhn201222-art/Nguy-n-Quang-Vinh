import '../models/enums.dart';
import '../models/player.dart';
import 'game_controller.dart';

void updateGame(GameController c, double dt) {
  if (c.player == null || c.screenSize.width == 0) return;

  // Di chuyển player
  double moveSpeed = 200.0;
  if (c.leftPressed) {
    c.player!.vel.x = -moveSpeed;
  } else if (c.rightPressed) {
    c.player!.vel.x = moveSpeed;
  } else {
    c.player!.vel.x = 0;
  }

  // Giới hạn trong màn hình
  if (c.player!.pos.x < 0) {
    c.player!.pos.x = 0;
    c.player!.vel.x = 0;
  }
  if (c.player!.pos.x + c.player!.width > c.screenSize.width) {
    c.player!.pos.x = c.screenSize.width - c.player!.width;
    c.player!.vel.x = 0;
  }

  // Cập nhật vật lý player
  c.player!.update(dt);

  // Camera theo player
  if (c.player!.pos.y < c.cameraY - 300) {
    c.cameraY = c.player!.pos.y + 300;
    
    // ← THÊM: Phát âm thanh điểm khi điểm số tăng
    int oldScore = c.score.current;
    c.score.increase();
    int newScore = c.score.current;
    
    // Phát âm thanh mỗi 10 điểm (hoặc 100 điểm nếu muốn ít hơn)
    if (newScore > oldScore && newScore % 400 == 0) {
      c.soundManager.playScore();
    }
  }

  // Cập nhật môi trường
  c.platformManager.updateAll(dt, c.screenSize.width);
  c.platformManager.ensurePlatforms(c.screenSize.width, c.cameraY);
  
  // Đảm bảo luôn có obstacles
  c.ensureObstacles();

  // Cập nhật obstacles
  for (var o in c.obstacles) {
    o.update(dt, c.screenSize.width);
  }

  // Kiểm tra va chạm
  _checkCollisions(c, dt);
  
  // Dọn dẹp
  _cleanup(c);
}

void _checkCollisions(GameController c, double dt) {
  if (c.player == null) return;
  
  c.hasLandedThisFrame = false;

  // Kiểm tra va chạm với platform (chỉ khi đang rơi)
  if (c.player!.vel.y > 0) {
    for (var p in c.platformManager.platforms) {
      final plat = p.rect;
      
      // Kiểm tra player có ở phía trên platform không
      bool isAbovePlatform = c.player!.pos.y + c.player!.height <= plat.top + 15;
      
      // Kiểm tra overlap theo trục X
      bool overlapX = c.player!.pos.x + c.player!.width > plat.left + 5 && 
                     c.player!.pos.x < plat.right - 5;

      if (isAbovePlatform && overlapX) {
        // Tính toán vị trí tiếp theo
        double nextY = c.player!.pos.y + c.player!.vel.y * dt;
        
        // Nếu sẽ đi qua platform trong frame này
        if (nextY + c.player!.height >= plat.top) {
          // Đặt player lên trên platform
          c.player!.pos.y = plat.top - c.player!.height;
          c.player!.vel.y = 0;
          c.player!.jump();

          // ← THÊM: Phát âm thanh nhảy
          c.soundManager.playJump();

          // Xử lý platform đặc biệt
          if (p.type == PlatformType.disappearing) {
            p.willDisappear = true;
            // ← THÊM: Âm thanh cho platform biến mất
            c.soundManager.playObstacleHit();
          }
          
          c.hasLandedThisFrame = true;
          c.fallTime = 0.0;
          break;
        }
      }
    }
  }

  // Đếm thời gian rơi
  if (!c.hasLandedThisFrame) {
    c.fallTime += dt;
  }

  // Kiểm tra va chạm với obstacles
  final playerRect = c.player!.toRect();
  for (var o in c.obstacles) {
    final obstacleRect = o.toRect();
    if (playerRect.overlaps(obstacleRect)) {
      // ← THÊM: Phát âm thanh va chạm trước khi game over
      c.soundManager.playObstacleHit();
      _gameOver(c);
      return;
    }
  }

  // Kiểm tra rơi xuống vùng chết (100px từ đáy màn hình)
  // Tính vị trí thực của player trên màn hình
  final playerScreenY = c.player!.pos.y - (c.cameraY - c.screenSize.height);
  final deathZoneY = c.screenSize.height - 100;
  
  if (playerScreenY >= deathZoneY) {
    _gameOver(c);
    return;
  }
}

void _gameOver(GameController c) {
  c.status = GameStatus.gameOver;
  
  // ← THÊM: Phát âm thanh game over
  c.soundManager.playGameOver();
  
  // ← THÊM: Dừng nhạc nền
  c.soundManager.stopBackgroundMusic();
  
  if (c.score.current > c.score.best) {
    c.score.best = c.score.current;
  }
  
  c.leaderboard.addScore(c.score.current);
}

void _cleanup(GameController c) {
  c.platformManager.platforms.removeWhere((p) => p.isGone);
}