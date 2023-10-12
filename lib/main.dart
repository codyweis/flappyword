import 'package:flame/game.dart';
import 'package:flappy_word/overlays/game_over_screen.dart';
import 'package:flappy_word/overlays/main_menu_screen.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SafeArea(
        child: GameWidget<FlappyWordGame>.controlled(
          gameFactory: FlappyWordGame.new,
          overlayBuilderMap: {
            'MainMenu': (_, game) => MainMenu(game: game),
            'GameOver': (_, game) => GameOver(game: game),
          },
          initialActiveOverlays: const ['MainMenu'],
        ),
      ),
    ),
  );
}
