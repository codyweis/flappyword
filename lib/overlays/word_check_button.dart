import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';

class WordCheckButtonComponent extends PositionComponent with TapCallbacks {
  late Sprite _buttonSprite;
  final FlappyWordGame game;

  WordCheckButtonComponent(this.game) {
    size = Vector2(80, 80); // Increased size
    anchor = Anchor.center;
  }

  @override
  Future<void> onLoad() async {
    super.onLoad();
    _buttonSprite = await Sprite.load('submit.png');

    // Positioning the button vertically centered and on the left side
    position = Vector2(
      0 + size.x / 2, // On the left but considering its anchor
      (game.size.y / 4) - (size.y / 2), // Centered vertically
    );
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    _buttonSprite.render(canvas, size: size);
  }

  bool isTapped(Offset position) {
    final topLeft = this.position - Vector2(size.x / 2, size.y / 2);
    final bottomRight = this.position + Vector2(size.x / 2, size.y / 2);
    return position.dx >= topLeft.x &&
        position.dx <= bottomRight.x &&
        position.dy >= topLeft.y &&
        position.dy <= bottomRight.y;
  }

  @override
  void onTapUp(TapUpEvent event) {
    game.checkWord();
  }
}
