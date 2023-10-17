import 'dart:async';
import 'dart:math';

import 'package:flame/components.dart' hide Block;
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flappy_word/components/animations/animated_message.dart';
import 'package:flappy_word/components/letter.dart';
import 'package:flappy_word/components/obstacles/obstacle.dart';
import 'package:flappy_word/components/platform.dart';
import 'package:flappy_word/components/player.dart';
import 'package:flappy_word/components/ui_elements/ground.dart';
import 'package:flappy_word/enums/difficulty.dart';
import 'package:flappy_word/managers/segment_manager.dart';
import 'package:flappy_word/models/character_variation.dart';
import 'package:flappy_word/models/game_character.dart';
import 'package:flappy_word/models/game_letter_model.dart';
import 'package:flappy_word/overlays/hud.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FlappyWordGame extends FlameGame
    with TapCallbacks, HasCollisionDetection, HasKeyboardHandlerComponents {
  late BlockManager blockManager;

  FlappyWordGame() {
    blockManager = BlockManager(this);
  }

  late CharacterVariation selectedCharacter =
      CharacterVariation(imagePath: '', displayPath: '');

  double worldDistanceTravelled = 0.0;

  List<GameLetter> collectedLetters = [];

  double objectSpeed = 0.0;
  late double lastBlockXPosition = 0.0;
  late UniqueKey lastBlockKey;
  late Set<String> wordList;
  final List<String> weightedLetters = _generateWeightedLetters();

  late Difficulty difficulty = Difficulty.medium;
  late int spawnChance = 10; // default value
  late double moveSpeed = 150;

  late bool gameStarted = false;

  int score = 0;
  int health = 2;

  late Player _player;

  Hud? hudComponent;

  @override
  final world = World();

  late final CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    await images.loadAll([
      'block.png',
      'classicbirdone.png',
      'classicbirdonesheet.png',
      'classicbirdtwo.png',
      'classicbirdtwosheet.png',
      'classicbirdthree.png',
      'classicbirdthreesheet.png',
      'devilbirdone.png',
      'devilbirdtwo.png',
      'dragonalienone.png',
      'dragonalienonesheet.png',
      'dragonalientwo.png',
      'dragonalientwosheet.png',
      'devilbirdonesheet.png',
      'devilbirdtwosheet.png',
      'fireSheet.png',
      'submit.png',
      'ground.png',
      'heart.png',
      'blank.png',
      'alphabet.png'
    ]);

    final prefs = await SharedPreferences.getInstance();
    selectedCharacter.imagePath =
        prefs.getString('selectedVariation') ?? 'devilbirdonesheet.png';
    selectedCharacter.stepTime = prefs.getDouble('characterStepTime') ?? 0.09;
    selectedCharacter.spriteAmount = prefs.getInt('characterSpriteAmount') ?? 8;
    selectedCharacter.size = prefs.getDouble('characterSize') ?? 100;

    wordList = await loadWordList();
    print('Word List Size: ${wordList.length}');

    cameraComponent = CameraComponent(world: world);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;
    await addAll([cameraComponent, world]);

    initializeGame();
  }

  Future<Set<String>> loadWordList() async {
    String wordListContent = await rootBundle.loadString('assets/wordlist.txt');
    return wordListContent.split('\n').map((word) => word.trim()).toSet();
  }

  setDifficulty(Difficulty newDifficulty) {
    difficulty = newDifficulty;

    switch (difficulty) {
      case Difficulty.easy:
        spawnChance = 15;
        moveSpeed = 120;
        break;
      case Difficulty.medium:
        spawnChance = 30;
        moveSpeed = 150;
        break;
      case Difficulty.hard:
        spawnChance = 50;
        moveSpeed = 175;
        break;
    }
  }

  void initializeGame() {
    // Remove old Hud if exists
    if (hudComponent != null) {
      remove(hudComponent!);
    }

    // Assume that size.x < 3200
    var segmentsToLoad = (size.x / 640).ceil();
    segmentsToLoad = segmentsToLoad.clamp(0, segments.length);

    for (var i = 0; i < segmentsToLoad; i++) {
      loadGameSegments(i, (640 * i).toDouble());
    }

    _player = Player(
        position: Vector2(128, canvasSize.y - 70),
        characterSize: selectedCharacter.size);
    world.add(_player);
    hudComponent = Hud();
    add(hudComponent!);
  }

  void playGame() {
    gameStarted = true;
    overlays.remove('MainMenu');
    overlays.add("SubmitButton");
  }

  void reset() {
    overlays.add("SubmitButton");
    gameStarted = true;
    score = 0;
    collectedLetters.clear();
    health = 2;
    initializeGame();
  }

  void resetMain() {
    score = 0;
    collectedLetters.clear();
    health = 2;
    initializeGame();
  }

  void changeCharacter(
      GameCharacter? newCharacter, CharacterVariation? newVariation) async {
    world.remove(_player);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedCharacter', newCharacter!.name);
    await prefs.setString('selectedVariation', newVariation!.imagePath);
    await prefs.setDouble('characterStepTime', newVariation.stepTime);
    await prefs.setInt('characterSpriteAmount', newVariation.spriteAmount);
    await prefs.setDouble('characterSize', newVariation.size);

    selectedCharacter.imagePath = newVariation.imagePath;
    selectedCharacter.stepTime = newVariation.stepTime;
    selectedCharacter.spriteAmount = newVariation.spriteAmount;
    selectedCharacter.size = newVariation.size;

    _player = Player(
        position: Vector2(128, canvasSize.y - 70),
        characterSize: newVariation.size);
    world.add(_player);
  }

  @override
  void update(double dt) {
    if (health <= 0) {
      overlays.add('GameOver');
      overlays.remove('MainMenu');
      overlays.remove("SubmitButton");
      gameStarted = false;
    }
    blockManager.update();
    super.update(dt);
  }

  @override
  void onTapUp(TapUpEvent event) {
    _player.jump();
  }

  @override
  Color backgroundColor() {
    return const Color.fromARGB(255, 192, 211, 219);
  }

  String getRandomLetter() {
    var rand = Random();
    return weightedLetters[rand.nextInt(weightedLetters.length)];
  }

  static List<String> _generateWeightedLetters() {
    const letterDistribution = {
      'a': 9,
      'b': 2,
      'c': 2,
      'd': 4,
      'e': 12,
      'f': 2,
      'g': 3,
      'h': 2,
      'i': 9,
      'j': 1,
      'k': 1,
      'l': 4,
      'm': 2,
      'n': 6,
      'o': 8,
      'p': 2,
      'q': 1,
      'r': 6,
      's': 4,
      't': 6,
      'u': 4,
      'v': 2,
      'w': 2,
      'x': 1,
      'y': 2,
      'z': 1
    };

    List<String> weightedLetters = [];

    letterDistribution.forEach((letter, count) {
      for (int i = 0; i < count; i++) {
        weightedLetters.add(letter);
      }
    });
    return weightedLetters;
  }

  void checkWord() {
    String collectedWord =
        collectedLetters.map((letter) => letter.letter).join();
    bool loseHealth = true;
    try {
      for (int length = collectedWord.length; length >= 3; length--) {
        for (int startIndex = 0;
            startIndex <= collectedWord.length - length;
            startIndex++) {
          String subWord =
              collectedWord.substring(startIndex, startIndex + length);
          print('Checking substring: $subWord');
          if (wordList.contains(subWord)) {
            print("Found word: $subWord");
            getGameLettersFromSubwordAndRemove(subWord);
            loseHealth = false;
            return;
          }
        }
      }
    } catch (e) {
      print(e);
    }

    if (loseHealth) health--;
    if (collectedLetters.length < 3) {
      showAnimatedMessage("Must have at least 3 letters!", 5);
    } else {
      showAnimatedMessage("No word found!", 5);
    }
  }

  List<int> findSubwordIndices(String subword, int startIndex) {
    List<int> indicesToRemove = [];
    int currentIndex = startIndex;
    for (var char in subword.split('')) {
      bool found = false;
      while (currentIndex < collectedLetters.length) {
        if (collectedLetters[currentIndex].letter == char) {
          indicesToRemove.add(currentIndex);
          found = true;
          currentIndex++;
          break;
        }
        currentIndex++;
      }
      if (!found) return [];
    }
    // Check if the indices are continuous
    for (int i = 0; i < indicesToRemove.length - 1; i++) {
      if (indicesToRemove[i] + 1 != indicesToRemove[i + 1]) {
        return []; // This sequence is not continuous, so we return an empty list.
      }
    }
    return indicesToRemove;
  }

  void getGameLettersFromSubwordAndRemove(String subword) {
    int sumValues = 0;
    List<int> indicesToRemove = [];
    for (int i = 0; i < collectedLetters.length; i++) {
      indicesToRemove = findSubwordIndices(subword, i);
      if (indicesToRemove.length == subword.length) break;
    }

    if (indicesToRemove.length != subword.length) {
      // Couldn't find a sequence in collectedLetters that matches the subword
      // Handle this case accordingly
      return;
    }

    for (int index in indicesToRemove) {
      sumValues += collectedLetters[index].value;
    }
    if (subword.length >= 8) {
      // triple word
      sumValues = sumValues * 3;
      showAnimatedMessage('Triple Word! Awesome!', 8.0); // 3 seconds
    } else if (subword.length >= 5) {
      // double word
      sumValues = sumValues * 2;
      showAnimatedMessage('Double Word! Good Job!', 8.0); // 3 seconds
    }

    print(
        "Initial collectedLetters: ${collectedLetters.map((l) => l.letter).join()}");
    print("Indices to remove: $indicesToRemove");

    // Sort the indices to remove in descending order
    indicesToRemove.sort((a, b) => b.compareTo(a));

    for (int index in indicesToRemove) {
      collectedLetters.removeAt(index);
    }

    print(
        "Final collectedLetters after removal: ${collectedLetters.map((l) => l.letter).join()}");

    hudComponent?.removeSubwordFromHUD(indicesToRemove);
    score += sumValues;
  }

  void showAnimatedMessage(String message, double duration,
      {Color color = Colors.red}) {
    final animatedMessage = AnimatedMessage(message, duration, color);
    // Place the message in the center of the screen (adjust as needed)

    try {
      animatedMessage.position = Vector2(canvasSize.x / 2, 100);

      animatedMessage.anchor = Anchor.center;

      print('Canvas Size: $canvasSize');

      add(animatedMessage);
    } catch (e) {
      print(e);
    }
  }

  void loadGameSegments(int segmentIndex, double xPositionOffset) {
    for (final block in segments[segmentIndex]) {
      addBlockToGame(block, xPositionOffset);
    }
  }

  void addBlockToGame(Block block, [double xPositionOffset = 0.0]) {
    switch (block.blockType) {
      case Obstacle:
        add(Obstacle(
            gridPosition: block.gridPosition, xOffset: xPositionOffset));
        break;
      case PlatformBlock:
        add(PlatformBlock(
            gridPosition: block.gridPosition, xOffset: xPositionOffset));
        break;
      case Letter:
        add(Letter(
            gridPosition: block.gridPosition,
            xOffset: xPositionOffset,
            char: getRandomLetter()));
        break;
      case GroundBlock:
        add(GroundBlock(
            gridPosition: block.gridPosition, xOffset: xPositionOffset));
        break;
      default:
        throw Exception('Unknown block type: ${block.blockType}');
    }
  }
}
