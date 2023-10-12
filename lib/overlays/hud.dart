import 'package:flame/components.dart';
import 'package:flappy_word/models/game_letter_model.dart';
import 'package:flappy_word/overlays/health.dart';
import 'package:flappy_word/overlays/word_check_button.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'dart:async' as t;

class LetterWithSubtextComponent extends PositionComponent {
  final TextComponent? mainText;
  final TextComponent? subText;

  LetterWithSubtextComponent({
    this.mainText,
    this.subText,
  });

  double opacity = 1.0;
  Duration fadeDuration = const Duration(milliseconds: 500);

  @override
  Future<void> onLoad() async {
    if (mainText != null) {
      add(mainText!);
      if (subText != null) {
        subText!.position =
            Vector2(0, mainText!.height); // Position subText below mainText
        add(subText!);
      }
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.saveLayer(
      toRect(),
      Paint()..color = Color.fromARGB((255 * opacity).toInt(), 255, 255, 255),
    );
    super.render(canvas);
    canvas.restore();
  }

  void highlight({Color color = Colors.green}) {
    mainText?.textRenderer = TextPaint(
      style: TextStyle(fontSize: 32, color: color),
    );
  }

  void fadeOut() {
    final startTime = DateTime.now();
    t.Timer.periodic(const Duration(milliseconds: 16), (timer) {
      final elapsed = DateTime.now().difference(startTime);
      final progress = elapsed.inMilliseconds / fadeDuration.inMilliseconds;
      opacity = (1.0 - progress).clamp(0.0, 1.0);

      if (opacity == 0) {
        timer.cancel();
      }
    });
  }
}

class Hud extends PositionComponent with HasGameRef<FlappyWordGame> {
  Hud({
    super.position,
    super.size,
    super.scale,
    super.angle,
    super.anchor,
    super.children,
    super.priority = 5,
  });

  // Define some padding for left and right side of screen
  final double screenPadding = 10.0;

  late TextComponent _scoreTextComponent;
  List<LetterWithSubtextComponent> letterComponents = [];
  late WordCheckButtonComponent _wordCheckButton;

  final double letterSpacing = 20.0;
  final Vector2 initialLetterPosition =
      Vector2(0, 20); // Starting position for the first letter
  int lastKnownLettersCount = 0;

  @override
  Future<void> onLoad() async {
    double heartYPosition =
        20; // Separate the heart component by 60 pixels on y-axis.
    for (var i = 1; i <= game.health; i++) {
      final positionX = 40 * i;
      await add(
        HeartHealthComponent(
          heartNumber: i,
          position: Vector2(positionX.toDouble(), heartYPosition),
          size: Vector2.all(32),
        ),
      );
    }
    _scoreTextComponent = TextComponent(
      text: '${game.score}',
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32, color: Colors.black),
      ),
      position: Vector2(screenPadding + (0.1 * game.size.x), 60),
    );
    add(_scoreTextComponent);

    _wordCheckButton = WordCheckButtonComponent(game);

    add(_wordCheckButton);
  }

  void _addLetterToHUD(GameLetter gameLetter) {
    var mainText = TextComponent(
      text: gameLetter.letter,
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 32, color: Colors.black),
      ),
      anchor: Anchor.center,
    );

    var subText = TextComponent(
      text: gameLetter.value.toString(),
      textRenderer: TextPaint(
        style: const TextStyle(fontSize: 16, color: Colors.grey),
      ),
      anchor: Anchor.center,
    );

    var letterComponent = LetterWithSubtextComponent(
      mainText: mainText,
      subText: subText,
    );

    double totalLetterWidth = 10 * letterSpacing;
    double startingXPosition = game.size.x - totalLetterWidth;

    letterComponent.position = Vector2(
        startingXPosition + (letterComponents.length * letterSpacing),
        initialLetterPosition.y);

    add(letterComponent);
    letterComponents.add(letterComponent);

    if (letterComponents.length > 10) {
      var letterToRemove = letterComponents.first;

      letterToRemove.highlight(color: Colors.red);
      letterToRemove.fadeOut();

      Future.delayed(LetterWithSubtextComponent().fadeDuration, () {
        remove(letterToRemove);
        letterComponents.removeAt(0);

        for (int i = 0; i < letterComponents.length; i++) {
          letterComponents[i].position = Vector2(
              startingXPosition + (i * letterSpacing), initialLetterPosition.y);
        }
      });

      game.collectedLetters.removeAt(0);
    }
  }

  void removeSubwordFromHUD(List<int> markedForRemoval) {
    List<LetterWithSubtextComponent> lettersToRemove = [];

    // Highlight and fade out each letter
    for (int index in markedForRemoval) {
      lettersToRemove.add(letterComponents[index]);
      letterComponents[index].highlight();
      letterComponents[index].fadeOut();
    }

    Future.delayed(LetterWithSubtextComponent().fadeDuration, () {
      for (var letter in lettersToRemove) {
        // This will ensure that the exact letter is removed,
        // without relying on its index position.
        remove(letter);
        letterComponents.remove(letter);
      }

      for (int i = 0; i < letterComponents.length; i++) {
        double startingXPosition = game.size.x - (10 * letterSpacing);
        letterComponents[i].position = Vector2(
            startingXPosition + (i * letterSpacing), initialLetterPosition.y);
      }
    });
  }

  @override
  void onRemove() {
    letterComponents.clear();
    lastKnownLettersCount = 0;

    return super.onRemove();
  }

  @override
  void update(double dt) {
    _scoreTextComponent.text = '${game.score}';

    if (game.collectedLetters.length != lastKnownLettersCount) {
      while (game.collectedLetters.length > letterComponents.length) {
        _addLetterToHUD(game.collectedLetters[letterComponents.length]);
      }
      lastKnownLettersCount = game.collectedLetters.length;
    }
  }
}
