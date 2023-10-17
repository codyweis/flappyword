import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flappy_word/screens/game_screen.dart';

class Obstacle extends SpriteAnimationComponent
    with HasGameRef<FlappyWordGame> {
  final Vector2 gridPosition;
  double xOffset;

  final Vector2 velocity = Vector2.zero();

  Obstacle({
    required this.gridPosition,
    required this.xOffset,
  }) : super(size: Vector2.all(64), anchor: Anchor.bottomLeft);

  @override
  void onLoad() {
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('fireSheet.png'),
      SpriteAnimationData.sequenced(
        amount: 25,
        textureSize: Vector2.all(100),
        stepTime: .05,
      ),
    );
    position = Vector2(
      (gridPosition.x * size.x) + xOffset + (size.x / 2),
      game.size.y - (gridPosition.y * size.y) - (size.y / 2),
    );
    add(CircleHitbox(collisionType: CollisionType.passive));
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
}
