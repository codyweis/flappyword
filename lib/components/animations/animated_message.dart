import 'package:flame/components.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';

class AnimatedMessage extends TextComponent with HasGameRef<FlappyWordGame> {
  double lifetime;

  double rotation = 0; // In radians
  double scaler = 1;
  bool shouldRotate = false;

  late double initialLifetime;
  AnimatedMessage(String message, this.lifetime, Color color)
      : super(text: message) {
    initialLifetime = lifetime;
    // Set the textRenderer using TextPaint
    textRenderer = TextPaint(style: TextStyle(color: color, fontSize: 32.0));
  }

  @override
  void render(Canvas canvas) {
    canvas.save();

    // Calculate center position for the rotation
    final centerX = position.x;
    final centerY = position.y;

    canvas.translate(centerX, centerY);
    canvas.rotate(rotation);
    canvas.scale(scaler);
    // Translate back after rotation and scaling to render text at correct position
    canvas.translate(-centerX, -centerY);

    super.render(canvas);
    canvas.restore();
  }

  @override
  void update(double dt) {
    super.update(dt);
    lifetime -= dt;

    scaler -= 0.5 * dt;
    if (scaler < 0) scaler = 0;

    if (lifetime <= 0) {
      gameRef.remove(this);
    }
  }
}
