// lib/models/platform.dart
import 'dart:math';
import 'package:flutter/material.dart';
import 'vector2.dart';
import 'enums.dart';

class Platform {
  Vector2 pos;
  double width;
  double height;
  PlatformType type;
  bool willDisappear = false;

  // thời gian đếm để platform thực sự biến mất (giây)
  double disappearTimer = 0.0;

  // cho platform di chuyển
  double speed = 40.0;
  int dir = 1;

  Platform({
    required this.pos,
    required this.width,
    required this.height,
    this.type = PlatformType.staticPlat,
  }) {
    if (type == PlatformType.moving) {
      // tốc độ ngẫu nhiên cho platform moving
      final rnd = Random();
      speed = 30 + rnd.nextDouble() * 80;
      dir = rnd.nextBool() ? 1 : -1;
    }
  }

  // gọi mỗi frame từ platformManager.updateAll(dt, screenWidth)
  void update(double dt, double screenWidth) {
    // simple moving behavior: di chuyển ngang, đổi chiều khi chạm biên
    if (type == PlatformType.moving) {
      pos.x += speed * dt * dir;
      if (pos.x <= 0) {
        pos.x = 0;
        dir = 1;
      } else if (pos.x + width >= screenWidth) {
        pos.x = screenWidth - width;
        dir = -1;
      }
    }

    // nếu đã bị kích hoạt biến mất, đếm thời gian
    if (willDisappear) {
      disappearTimer += dt;
    }
  }

  // trả true nếu platform đã đủ thời gian để bị remove
  bool get isGone => willDisappear && disappearTimer > 0.5; // 0.5s sau mới remove

  Rect get rect => Rect.fromLTWH(pos.x, pos.y, width, height);
 
}
