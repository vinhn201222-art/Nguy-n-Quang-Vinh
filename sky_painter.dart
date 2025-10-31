import 'package:flutter/material.dart';
import 'dart:math';

class SkyPainter {
  void drawSky(Canvas canvas, Size size) {
    // 🌇 Nền trời hoàng hôn ấm áp
    final Rect fullScreen = Rect.fromLTWH(0, 0, size.width, size.height);

    final bgPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFF8C42), // Cam đậm trên cùng (ánh hoàng hôn)
          Color(0xFFFFB347), // Cam nhạt dần
          Color(0xFFFFE29F), // Vàng nhạt pha hồng
          Color(0xFF87CEEB), // Xanh trời nhạt phía dưới chân trời
        ],
        stops: [0.0, 0.4, 0.7, 1.0],
      ).createShader(fullScreen);

    canvas.drawRect(fullScreen, bgPaint);

    // ☁️ Ánh sáng loang của mây khi mặt trời sắp lặn
    final warmGlow = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0.0, 0.4),
        radius: 0.8,
        colors: [
          Colors.orangeAccent.withOpacity(0.3),
          Colors.pinkAccent.withOpacity(0.1),
          Colors.transparent,
        ],
      ).createShader(fullScreen);

    canvas.drawRect(fullScreen, warmGlow);

    // Tiếp tục vẽ các chi tiết khác
    drawStars(canvas, size);
    drawSun(canvas, size);
    drawClouds(canvas, size);
  }

  // 🌟 Một ít sao nhỏ vẫn còn nhìn thấy lúc hoàng hôn
  void drawStars(Canvas canvas, Size size) {
    final starPaint = Paint()..color = Colors.white.withOpacity(0.25);
    final random = Random(42);

    for (int i = 0; i < 60; i++) {
      double x = random.nextDouble() * size.width;
      double y = random.nextDouble() * size.height * 0.5; // chỉ phần trên
      double radius = random.nextDouble() * 1.2 + 0.3;
      canvas.drawCircle(Offset(x, y), radius, starPaint);
    }
  }

  // 🌞 Mặt trời đang lặn
  void drawSun(Canvas canvas, Size size) {
    final sunX = size.width * 0.7;
    final sunY = size.height * 0.65;

    final sunPaint = Paint()..color = const Color(0xFFFFE082);
    canvas.drawCircle(Offset(sunX, sunY), 45, sunPaint);

    final glowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFC107).withOpacity(0.6),
          const Color(0xFFFF7043).withOpacity(0.2),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(sunX, sunY), radius: 120));
    canvas.drawCircle(Offset(sunX, sunY), 120, glowPaint);
  }

  // ☁️ Mây hồng, cam, tím đặc trưng của hoàng hôn
  void drawClouds(Canvas canvas, Size size) {
    final random = Random(123);

    final cloudColors = [
      const Color.fromARGB(180, 255, 204, 188), // hồng nhạt
      const Color.fromARGB(160, 255, 171, 145), // cam hồng
      const Color.fromARGB(180, 255, 255, 255), // trắng sáng
    ];

    for (int i = 0; i < 6; i++) {
      final paint = Paint()
        ..color = cloudColors[i % cloudColors.length]
        ..style = PaintingStyle.fill;

      double x = random.nextDouble() * (size.width + 100) - 50;
      double y = random.nextDouble() * size.height * 0.6;

      canvas.drawCircle(Offset(x, y), 30, paint);
      canvas.drawCircle(Offset(x + 25, y - 5), 35, paint);
      canvas.drawCircle(Offset(x + 55, y), 30, paint);
      canvas.drawCircle(Offset(x + 20, y - 10), 25, paint);
    }
  }
}
