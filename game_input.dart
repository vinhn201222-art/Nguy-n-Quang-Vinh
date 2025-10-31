import 'package:flutter/services.dart';
import 'game_controller.dart';

void handleKeyboardInput(KeyEvent event, GameController c) {
  final key = event.logicalKey;
  
  if (event is KeyDownEvent) {
    if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
      c.leftPressed = true;
    }
    if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight) {
      c.rightPressed = true;
    }
  } else if (event is KeyUpEvent) {
    if (key == LogicalKeyboardKey.keyA || key == LogicalKeyboardKey.arrowLeft) {
      c.leftPressed = false;
    }
    if (key == LogicalKeyboardKey.keyD || key == LogicalKeyboardKey.arrowRight) {
      c.rightPressed = false;
    }
  }
}