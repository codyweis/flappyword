import 'dart:math';

import 'package:flame/components.dart';
import 'package:flappy_word/components/letter.dart';
import 'package:flappy_word/components/obstacles/obstacle.dart';
import 'package:flappy_word/components/ui_elements/ground.dart';
import 'package:flappy_word/enums/difficulty.dart';
import 'package:flappy_word/screens/game_screen.dart';

class Block {
  // gridPosition position is always segment based X,Y.
  // 0,0 is the bottom left corner.
  // 10,10 is the upper right corner.
  final Vector2 gridPosition;
  final Type blockType;
  final String? char;
  Block(this.gridPosition, this.blockType, {this.char});
}

class BlockManager {
  final FlappyWordGame game;
  BlockManager(this.game);

  List<Block> activeBlocks = [];
  double lastBlockXPosition = 0.0;
  final double distanceBetweenBlocks = 25.0;

  // instance variable to keep track of the last rounded distance at which a block was spawned.
  int lastRoundedDistanceSpawned = 0;

  void update() {
    if (game.gameStarted) {
      int roundedDistance = (game.worldDistanceTravelled ~/ 300) * 100;
      if (roundedDistance > lastRoundedDistanceSpawned) {
        int randomChance =
            _rand.nextInt(100); // Generates a number between 0 and 99 inclusive

        int spawnChance;
        switch (game.difficulty) {
          case Difficulty.easy:
            spawnChance = 10;
            break;
          case Difficulty.medium:
            spawnChance = 30;
            break;
          case Difficulty.hard:
            spawnChance = 50;
            break;
          default:
            spawnChance =
                10; // Default to easy if somehow there's no difficulty set
        }

        if (randomChance < spawnChance) {
          spawnObstacle();
        } else {
          spawnNewBlock();
        }

        lastRoundedDistanceSpawned = roundedDistance;
      }
    }
  }

  void spawnObstacle() {
    int minYGapStart = 1; // The minimum height at which the gap can start.
    int maxYGapStart = 9; // The maximum height at which the gap can start.

    int gapStart = minYGapStart + _rand.nextInt(maxYGapStart - minYGapStart);
    int gapSize = 4;

    bool shouldSpawnLetterInGap = _rand.nextDouble() < 0.5; // 50% chance
    int letterYPosition = 0;

    if (shouldSpawnLetterInGap) {
      letterYPosition =
          gapStart + _rand.nextInt(gapSize); // Random position within the gap
    }

    for (int y = 0; y <= 12; y++) {
      if (y < gapStart || y > gapStart + gapSize) {
        Block block = Block(Vector2(10.toDouble(), y.toDouble()), Obstacle);
        activeBlocks.add(block);
        game.addBlockToGame(block);
      } else if (shouldSpawnLetterInGap && y == letterYPosition) {
        Block newBlock = Block(Vector2(10.toDouble(), y.toDouble()), Letter,
            char: game.getRandomLetter());
        activeBlocks.add(newBlock);
        game.addBlockToGame(newBlock);
      }
    }

    // Logic for removing off-screen blocks remains the same.
    activeBlocks.removeWhere(
        (block) => block.gridPosition.x < game.worldDistanceTravelled);
  }

  void spawnNewBlock() {
    Vector2 position;
    bool isOverlap;
    do {
      position = generateRandomPosition();
      isOverlap = activeBlocks.any((block) => block.gridPosition == position);
    } while (isOverlap);

    Block newBlock = Block(position, Letter, char: game.getRandomLetter());
    activeBlocks.add(newBlock);
    game.addBlockToGame(newBlock); // integrate with the game world.

    // Logic for removing off-screen blocks remains the same.
    activeBlocks.removeWhere(
        (block) => block.gridPosition.x < game.worldDistanceTravelled);

    print("New block spawned at: ${newBlock.gridPosition.x}");
    print("World distance travelled: ${game.worldDistanceTravelled}");
  }
}

final segments = [segment0];

Random _rand = Random();

Vector2 generateRandomPosition() {
  int x = 10;
  int y = 1 + _rand.nextInt(9); // Starts from 1, goes up to 9
  return Vector2(x.toDouble(), y.toDouble());
}

List<Block> generateRandomLetters(int numLetters, List<Block> existingBlocks) {
  List<Block> newLetters = [];
  for (int i = 0; i < numLetters; i++) {
    Vector2 position;
    bool isOverlap;
    do {
      position = generateRandomPosition();
      isOverlap = existingBlocks.any((block) => block.gridPosition == position);
    } while (isOverlap);
    newLetters.add(Block(position, Letter));
  }
  return newLetters;
}

final segmentWithRandomLetters = [
  ...generateRandomLetters(1, segment0),
];

final segment0 = [
  Block(Vector2(0, 0), GroundBlock),
  Block(Vector2(1, 0), GroundBlock),
  Block(Vector2(2, 0), GroundBlock),
  Block(Vector2(3, 0), GroundBlock),
  Block(Vector2(4, 0), GroundBlock),
  Block(Vector2(5, 0), GroundBlock),
  Block(Vector2(6, 0), GroundBlock),
  Block(Vector2(7, 0), GroundBlock),
  Block(Vector2(8, 0), GroundBlock),
  Block(Vector2(9, 0), GroundBlock),
  Block(Vector2(10, 0), GroundBlock),
];
