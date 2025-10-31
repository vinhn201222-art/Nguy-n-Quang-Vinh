import 'dart:ui';
import 'enums.dart';

class Obstacle {
  Offset pos;
  double width;
  double height;
  ObstacleType type;
  
  // Di chuyển ngang
  double moveRange; // phạm vi di chuyển (tính từ originX)
  double moveSpeed; // px / s
  double originX; // vị trí ban đầu (để giới hạn phạm vi)
  bool movingRight = true;

  Obstacle({
    required this.pos,
    required this.width,
    required this.height,
    required this.type,
    this.moveRange = 0,
    this.moveSpeed = 0,
  }) : originX = pos.dx;

  /// Cập nhật vị trí theo thời gian dt
  void update(double dt, [double? screenWidth]) {
    if (moveRange > 0 && moveSpeed != 0) {
      final dx = moveSpeed * dt * (movingRight ? 1 : -1);
      pos = Offset(pos.dx + dx, pos.dy);
      
      // Nếu vượt quá phạm vi cho phép thì đổi hướng
      if (movingRight && pos.dx >= originX + moveRange) {
        movingRight = false;
        pos = Offset(originX + moveRange, pos.dy);
      } else if (!movingRight && pos.dx <= originX) {
        movingRight = true;
        pos = Offset(originX, pos.dy);
      }
      
      // Tránh chạm mép màn hình
      if (screenWidth != null) {
        if (pos.dx < 0) {
          pos = Offset(0, pos.dy);
          originX = 0;
          movingRight = true;
        }
        if (pos.dx + width > screenWidth) {
          pos = Offset(screenWidth - width, pos.dy);
          originX = screenWidth - width - moveRange;
          movingRight = false;
        }
      }
    }
  }

  /// Hình chữ nhật để kiểm tra va chạm
  Rect get rect => Rect.fromLTWH(pos.dx, pos.dy, width, height);

  /// Tạo rect nhanh (dùng ở chỗ khác)
  Rect toRect() => Rect.fromLTWH(pos.dx, pos.dy, width, height);
  
  /// Lấy các điểm của hình tam giác mũi nhọn chỉ xuống
  /// Đỉnh nhọn ở dưới, đáy ở trên
  Path getSpikeDownPath() {
    final path = Path();
    path.moveTo(pos.dx, pos.dy); // trái trên
    path.lineTo(pos.dx + width, pos.dy); // phải trên
    path.lineTo(pos.dx + width / 2, pos.dy + height); // nhọn dưới giữa
    path.close();
    return path;
  }
}
