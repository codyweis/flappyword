import 'package:flame/game.dart';
import 'package:flappy_word/overlays/game_over_screen.dart';
import 'package:flappy_word/overlays/main_menu_screen.dart';
import 'package:flappy_word/overlays/word_check_button.dart';
import 'package:flappy_word/screens/game_screen.dart'; // Ensure this import is correct
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: GameWidget<FlappyWordGame>.controlled(
          gameFactory: () => FlappyWordGame(),
          overlayBuilderMap: {
            'MainMenu': (_, game) => MainMenu(game: game),
            'GameOver': (_, game) => GameOver(game: game),
            'SubmitButton': (_, game) => WordCheckButton(game: game)
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    ),
  );
}
