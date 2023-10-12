import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';

class Letter extends SpriteComponent with HasGameRef<FlappyWordGame> {
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();
  final String char; // This stores the character (a, b, c, ...)

  static const int letterWidth = 80;
  static const int letterHeight = 80;

  // Adding a padding for the circle bubble around the letter
  static const double padding = 1;

  late TextPainter _textPainter; // TextPainter for rendering text

  static const Map<String, int> letterOffsets = {
    'a': 0,
    'b': 1,
    'c': 2,
    'd': 3,
    'e': 4,
    'f': 5,
    'g': 6,
    'h': 7,
    'i': 8,
    'j': 9,
    'k': 10,
    'l': 11,
    'm': 12,
    'n': 13,
    'o': 14,
    'p': 15,
    'q': 16,
    'r': 17,
    's': 18,
    't': 19,
    'u': 20,
    'v': 21,
    'w': 22,
    'x': 23,
    'y': 24,
    'z': 25,
  };

  static const Map<String, int> letterValues = {
    'a': 1,
    'b': 3,
    'c': 3,
    'd': 2,
    'e': 1,
    'f': 4,
    'g': 2,
    'h': 4,
    'i': 1,
    'j': 8,
    'k': 5,
    'l': 1,
    'm': 3,
    'n': 1,
    'o': 1,
    'p': 3,
    'q': 10,
    'r': 1,
    's': 1,
    't': 1,
    'u': 1,
    'v': 4,
    'w': 4,
    'x': 8,
    'y': 4,
    'z': 10,
  };

  Letter({
    required this.gridPosition,
    required this.xOffset,
    required this.char,
  }) : super(
            size: Vector2.all(letterWidth + 2 * padding),
            anchor: Anchor.center);

  @override
  void onLoad() {
    _textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    final spriteSheet = game.images.fromCache('alphabet.png');

    int offsetX =
        (letterOffsets[char] ?? letterOffsets['a']!) % 8 * letterWidth;
    int offsetY =
        (letterOffsets[char] ?? letterOffsets['a']!) ~/ 8 * letterHeight;

    sprite = Sprite(spriteSheet,
        srcPosition: Vector2(offsetX.toDouble(), offsetY.toDouble()),
        srcSize: Vector2(letterWidth.toDouble(), letterHeight.toDouble()));

    position = Vector2(
      (gridPosition.x * size.x) + xOffset + (size.x / 2),
      game.size.y - (gridPosition.y * size.y) - (size.y / 2),
    );

    add(RectangleHitbox(collisionType: CollisionType.passive));
    add(
      SizeEffect.by(
        Vector2(-24, -24),
        EffectController(
          duration: .75,
          reverseDuration: .5,
          infinite: true,
          curve: Curves.easeOut,
        ),
      ),
    );
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;
    if (position.x < -size.x || game.health <= 0) {
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Render the sprite

    // Update the text to be painted
    _textPainter.text = TextSpan(
      text: letterValues[char]?.toString() ?? '0',
      style: const TextStyle(
        color: Colors.black,
        fontSize: 24.0,
      ),
    );
    _textPainter.layout();

    // Calculate position for the value (e.g., bottom-right of the sprite)
    final textPosition =
        Vector2(-_textPainter.width / 2, -_textPainter.height / 2);

    // Render the letter's value
    _textPainter.paint(canvas, Offset(textPosition.x, textPosition.y));
  }
}
