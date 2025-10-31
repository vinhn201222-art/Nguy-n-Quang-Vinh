import 'vector2.dart';
import 'package:flutter/material.dart';

class Player {
  Vector2 pos;
  Vector2 vel;
  final double width;
  final double height;
  double jumpStrength;

  Player({
    required this.pos,
    required this.width,
    required this.height,
    this.jumpStrength = 650,
  }) : vel = Vector2(0, 0);

  // 🟢 Chỉ giữ lại hàm toRect duy nhất này:
  Rect toRect() => Rect.fromLTWH(pos.x, pos.y, width, height);

  void update(double dt) {
    vel.y += 1200 * dt; // gravity
    pos.x += vel.x * dt;
    pos.y += vel.y * dt;
  }

  void moveLeft() => vel.x = -260;
  void moveRight() => vel.x = 260;
  void stopHorizontal() => vel.x = 0;

  void jump() {
    vel.y = -jumpStrength;
  }
}
