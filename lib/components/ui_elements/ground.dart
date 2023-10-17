import 'dart:math';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flappy_word/managers/segment_manager.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';

class GroundBlock extends SpriteAnimationComponent
    with HasGameRef<FlappyWordGame> {
  final Vector2 gridPosition;
  double xOffset;

  final UniqueKey _blockKey = UniqueKey();
  final Vector2 velocity = Vector2.zero();

  GroundBlock({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ground.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(50),
        stepTime: 1, // Adjust this as needed
      ),
    );
    position = Vector2(
      gridPosition.x * size.x + xOffset,
      game.size.y - gridPosition.y * size.y,
    );
    add(CircleHitbox(collisionType: CollisionType.passive));
    if (gridPosition.x == 9 && position.x > game.lastBlockXPosition) {
      game.lastBlockKey = _blockKey;
      game.lastBlockXPosition = position.x + size.x;
    }
  }

  @override
  void update(double dt) {
    velocity.x = game.objectSpeed;
    position += velocity * dt;

    if (position.x < -size.x) {
      removeFromParent();
      if (gridPosition.x == 0) {
        game.loadGameSegments(
          Random().nextInt(segments.length),
          game.lastBlockXPosition,
        );
      }
    }
    if (gridPosition.x == 9) {
      if (game.lastBlockKey == _blockKey) {
        game.lastBlockXPosition = position.x + size.x - 10;
      }
    }
    if (game.health <= 0) {
      removeFromParent();
    }

    super.update(dt);
  }
}
