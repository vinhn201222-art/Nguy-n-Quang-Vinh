import 'package:flutter/material.dart';

/// NÚT CƠ SỞ
abstract class GameButton extends StatefulWidget {
  final IconData icon;
  final VoidCallback onPressedDown;
  final VoidCallback? onPressedUp;

  const GameButton({
    required this.icon,
    required this.onPressedDown,
    this.onPressedUp,
    super.key,
  });
}

class _GameButtonState extends State<GameButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) {
        if (!_isPressed) {
          setState(() => _isPressed = true);
          widget.onPressedDown();
        }
      },
      onPointerUp: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
          widget.onPressedUp?.call();
        }
      },
      onPointerCancel: (_) {
        if (_isPressed) {
          setState(() => _isPressed = false);
          widget.onPressedUp?.call();
        }
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: _isPressed ? Colors.white38 : Colors.white24,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(
            color: _isPressed ? Colors.white70 : Colors.white54, 
            width: 2
          ),
        ),
        child: Icon(
          widget.icon, 
          color: Colors.white, 
          size: 28
        ),
      ),
    );
  }
}

/// NÚT CỤ THỂ
class LeftButton extends GameButton {
  const LeftButton({
    required super.onPressedDown,
    required super.onPressedUp,
    super.key,
  }) : super(icon: Icons.arrow_left);

  @override
  State<GameButton> createState() => _GameButtonState();
}

class RightButton extends GameButton {
  const RightButton({
    required super.onPressedDown,
    required super.onPressedUp,
    super.key,
  }) : super(icon: Icons.arrow_right);

  @override
  State<GameButton> createState() => _GameButtonState();
}

/// CỤM NÚT: Trái & Phải
class GameButtonsOverlay extends StatelessWidget {
  final bool visible;
  final VoidCallback onLeftDown;
  final VoidCallback onLeftUp;
  final VoidCallback onRightDown;
  final VoidCallback onRightUp;

  const GameButtonsOverlay({
    required this.visible,
    required this.onLeftDown,
    required this.onLeftUp,
    required this.onRightDown,
    required this.onRightUp,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (!visible) return const SizedBox.shrink();

    return Stack(
      children: [
        // Nút trái - góc dưới trái
        Positioned(
          bottom: 30,
          left: 20,
          child: LeftButton(onPressedDown: onLeftDown, onPressedUp: onLeftUp),
        ),
        // Nút phải - góc dưới phải
        Positioned(
          bottom: 30,
          right: 20,
          child: RightButton(onPressedDown: onRightDown, onPressedUp: onRightUp),
        ),
      ],
    );
  }
}