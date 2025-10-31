import 'dart:math';
import 'platform.dart';
import 'vector2.dart';
import 'enums.dart';

class PlatformManager {
  final List<Platform> platforms = [];
  final Random rng = Random();

  void seedInitial(double screenWidth, double screenHeight) {
    platforms.clear();
    // Platform ban đầu ở dưới cùng
    platforms.add(Platform(
      pos: Vector2(screenWidth / 2 - 50, screenHeight - 50),
      width: 100,
      height: 20,
    ));
    // Tạo 8 platform phía trên
    for (int i = 1; i < 8; i++) {
      double y = screenHeight - 60.0 * i;
      platforms.add(_createRandomPlatform(screenWidth, y));
    }
  }

  Platform _createRandomPlatform(double screenWidth, double y) {
    // Kích thước platform: 60-100px
    double w = rng.nextDouble() * 40 + 60;
    // Vị trí random nhưng không quá sát biên
    double x = rng.nextDouble() * (screenWidth - w);
    x = x.clamp(10, screenWidth - w - 10);
    
    PlatformType type;
    double p = rng.nextDouble();
      if (p < 0.6) {
      type = PlatformType.staticPlat; // 60% static (xanh)
    } else if (p < 0.95) {
      type = PlatformType.moving; // 35% moving (cam)
    } else {
      type = PlatformType.disappearing; // 5% disappearing (đỏ)
    }
    
    return Platform(
      pos: Vector2(x, y),
      width: w,
      height: 15,
      type: type,
    );
  }

  void updateAll(double dt, double screenWidth) {
    for (var p in platforms) {
      p.update(dt, screenWidth);
    }
    // Xóa platform đã biến mất hoặc ra khỏi màn hình (tăng 3000 để giữ lâu hơn)
    platforms.removeWhere((p) => p.isGone || p.pos.y > 2000);
  }

  void ensurePlatforms(double screenWidth, double cameraY) {
    if (platforms.isEmpty) return;

    double topY = platforms.map((p) => p.pos.y).reduce(min);

    // Tạo platform mới khi camera lên cao
    while (topY > cameraY - 1000) {
      // Khoảng cách tăng dần theo độ cao (tăng chậm hơn)
      double difficulty = (cameraY / 2000).clamp(0, 1);
      // Khoảng cách: 80-120px (tăng từ 80 đến 120)
      double gap = 65 + difficulty * 30;
      double variance = rng.nextDouble() * 15;
      double newY = topY - (gap + variance);
      
      platforms.add(_createRandomPlatform(screenWidth, newY));
      topY = newY;
    }
  }
  void reset() {
    platforms.clear();
  }
}
