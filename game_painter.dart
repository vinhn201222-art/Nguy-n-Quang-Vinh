import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import '../models/player.dart';
import '../models/platform.dart';
import '../models/enums.dart';
import '../models/obstacle.dart';
import './sky_painter.dart';

class GamePainter extends CustomPainter {
  final Player? player;
  final List<Platform> platforms;
  final List<Obstacle> obstacles;
  final double cameraY;
  final ui.Image? playerImage;
  final SkyPainter skyPainter = SkyPainter();

  GamePainter({
    required this.player,
    required this.platforms,
    required this.obstacles,
    required this.cameraY,
    required this.playerImage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 🟦 BƯỚC 1: Vẽ nền trời đầy tiên - KHÔNG dịch canvas
    skyPainter.drawSky(canvas, size);

    // 🎥 BƯỚC 2: Sau đó mới dịch canvas để vẽ game objects
    canvas.save();
    canvas.translate(0, size.height - cameraY);

    final paint = Paint();

    // 🟢 Vẽ platforms
    for (final p in platforms) {
      paint.color = switch (p.type) {
        PlatformType.staticPlat => Colors.green,
        PlatformType.moving => Colors.orange,
        PlatformType.disappearing => Colors.purple,
      };

      // Nếu platform đang biến mất, làm mờ dần
      if (p.willDisappear) {
        paint.color = paint.color.withOpacity(1.0 - (p.disappearTimer / 0.5).clamp(0.0, 1.0));
      }

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(p.pos.x, p.pos.y, p.width, p.height),
          const Radius.circular(5),
        ),
        paint,
      );
    }

    // 🔺 Vẽ obstacles
    for (var o in obstacles) {
      final spikePath = o.getSpikeDownPath();
      
      // Màu fill
      canvas.drawPath(
        spikePath,
        Paint()
          ..color = o.type == ObstacleType.spike ? Colors.red : Colors.orange
          ..style = PaintingStyle.fill,
      );
      
      // Viền đen
      canvas.drawPath(
        spikePath,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // 🔴 Vẽ player
    if (player != null) {
      if (playerImage != null) {
        final playerRect = Rect.fromLTWH(
          player!.pos.x,
          player!.pos.y,
          player!.width,
          player!.height,
        );
        canvas.drawImageRect(
          playerImage!,
          Rect.fromLTWH(
            0,
            0,
            playerImage!.width.toDouble(),
            playerImage!.height.toDouble(),
          ),
          playerRect,
          Paint(),
        );
      } else {
        // Vẽ hình Among Us mặc định
        drawAmongUs(
          canvas,
          Offset(player!.pos.x, player!.pos.y),
          player!.width,
          player!.height,
          Colors.red,
        );
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void drawAmongUs(Canvas canvas, Offset position, double width, double height, Color color) {
  final bodyPaint = Paint()..color = color;
  final visorPaint = Paint()..color = const Color(0xFF9AD9E8);

  // Body
  final bodyRect = Rect.fromLTWH(position.dx, position.dy, width, height);
  canvas.drawRRect(
    RRect.fromRectAndRadius(bodyRect, Radius.circular(width / 3)), 
    bodyPaint
  );

  // Visor (kính)
  final visorRect = Rect.fromLTWH(
    position.dx + width * 0.2,
    position.dy + height * 0.25,
    width * 0.6,
    height * 0.3,
  );
  canvas.drawRRect(
    RRect.fromRectAndRadius(visorRect, const Radius.circular(10)), 
    visorPaint
  );
}