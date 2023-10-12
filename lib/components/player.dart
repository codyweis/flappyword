import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flappy_word/components/letter.dart';
import 'package:flappy_word/components/obstacles/obstacle.dart';
import 'package:flappy_word/components/platform.dart';
import 'package:flappy_word/components/ui_elements/ground.dart';
import 'package:flappy_word/models/game_letter_model.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flappy_word/utils/helpers.dart';
import 'package:flutter/material.dart';

class Player extends SpriteAnimationComponent
    with CollisionCallbacks, HasGameRef<FlappyWordGame> {
  final Vector2 velocity;
  final double jumpSpeed = 300; // Define how "strong" the jump is

  final double terminalVelocity = 600;

  final Vector2 fromAbove = Vector2(0, -1);
  bool isOnGround = false;

  final double gravity = 600; // Pixels per second squared

  bool hitByEnemy = false;
  double moveSpeed = 150;

  Player({required Vector2 position})
      : velocity = Vector2.zero(),
        super(position: position, size: Vector2.all(64), anchor: Anchor.center);

  @override
  void onLoad() {
    moveSpeed = game.moveSpeed;
    animation = SpriteAnimation.fromFrameData(
      game.images.fromCache('ball.png'),
      SpriteAnimationData.sequenced(
        amount: 1,
        textureSize: Vector2.all(16),
        stepTime: 0.12,
      ),
    );
    add(
      CircleHitbox(),
    );
  }

  void jump() {
    // Apply the jump speed to the y-axis of the velocity
    velocity.y = -jumpSpeed;
  }

  @override
  void update(double dt) {
    if (position.x + width < game.size.x / 2) {
      velocity.x = moveSpeed;
    } else {
      velocity.x = 0;
    }
    if (position.x + 64 >= game.size.x / 2 || game.gameStarted == false) {
      game.objectSpeed = -moveSpeed;
      game.worldDistanceTravelled -= game.objectSpeed * dt;
    }
    if (game.gameStarted) {
      position += velocity * dt;

      // Gravity to make the character fall back down after a jump
      velocity.y += gravity * dt;

      // Apply terminal velocity
      velocity.y = velocity.y.clamp(-jumpSpeed, terminalVelocity);

      // If ember fell in pit, then game over.
      if (position.y > game.size.y + size.y && game.gameStarted == true) {
        game.health = 0;
      }
    }
    if (game.health <= 0) {
      saveHighScore(game.score, game.difficulty);
      removeFromParent();
    }
    super.update(dt);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is GroundBlock || other is PlatformBlock) {
      if (intersectionPoints.length == 2) {
        // Calculate the collision normal and separation distance.
        final mid = (intersectionPoints.elementAt(0) +
                intersectionPoints.elementAt(1)) /
            2;

        final collisionNormal = absoluteCenter - mid;
        final separationDistance = (size.x / 2) - collisionNormal.length;
        collisionNormal.normalize();

        // If collision normal is almost upwards,
        // ember must be on ground.
        if (fromAbove.dot(collisionNormal) > 0.9) {
          isOnGround = true;
        }

        // Resolve collision by moving ember along
        // collision normal by separation distance.
        position += collisionNormal.scaled(separationDistance);
      }
    }
    if (other is Letter) {
      other.removeFromParent();

      GameLetter collectedLetter = GameLetter(
        other.char,
      );

      if (game.collectedLetters.length == 10) {
        // Show the negative points animation
        showNegativePointAnimation(game.collectedLetters.first.value,
            Vector2(other.position.x, game.size.y * 0.1));
        game.score -= game.collectedLetters.first.value;
      } else {
        game.score += collectedLetter.value;
      }

      game.collectedLetters.add(collectedLetter);
    }

    if (other is Obstacle) {
      hit();
    }

    super.onCollision(intersectionPoints, other);
  }

  void showNegativePointAnimation(int points, Vector2 position) {
    const negativePointsStyle = TextStyle(
      fontSize: 48,
      color: Colors.red,
    );

    final negativePointsText = FadingTextComponent(
      text: '-$points',
      style: negativePointsStyle,
      position: Vector2.copy(position),
    );

    game.add(negativePointsText);
  }

  // This method runs an opacity effect to make it blink.
  void hit() {
    if (!hitByEnemy) {
      game.health--;
      hitByEnemy = true;
    }
    add(
      OpacityEffect.fadeOut(
        EffectController(
          alternate: true,
          duration: 0.1,
          repeatCount: 5,
        ),
      )..onComplete = () {
          hitByEnemy = false;
        },
    );
  }
}

class FadingTextComponent extends PositionComponent {
  final TextStyle style;
  final String text;
  double opacity;
  double time = 0.0;

  FadingTextComponent({
    required this.text,
    required this.style,
    required Vector2 position,
    this.opacity = 1.0,
  }) : super(position: position, anchor: Anchor.center);

  @override
  void render(Canvas canvas) {
    final textPainter = TextPainter(
      text: TextSpan(
          text: text,
          style: style.copyWith(color: style.color?.withOpacity(opacity))),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(canvas, Vector2.zero().toOffset());
  }

  @override
  void update(double dt) {
    super.update(dt);
    time += dt;
    opacity = (1.5 - time).clamp(0.0, 1.0); // Fade over 1.5 seconds

    if (opacity == 0) {
      removeFromParent(); // Remove when fully transparent
    }
  }
}
