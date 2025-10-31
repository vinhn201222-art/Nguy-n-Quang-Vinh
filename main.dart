import 'package:flutter/material.dart';
import 'game_screen.dart';
import 'package:flutter/services.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Tắt tất cả overlay warnings
  FlutterError.onError = (FlutterErrorDetails details) {
    // Không làm gì - bỏ qua tất cả errors
  };
  
  runApp(SquidJumpApp());
}

class SquidJumpApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doodle Jump',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: GameScreen(),
    );
  }
}