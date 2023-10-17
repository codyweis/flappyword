import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animated_button/flutter_animated_button.dart';

class WordCheckButton extends StatefulWidget {
  final FlappyWordGame game;
  const WordCheckButton({super.key, required this.game});

  @override
  State<WordCheckButton> createState() => _WordCheckButtonState();
}

class _WordCheckButtonState extends State<WordCheckButton> {
  bool _isSelected = false;

  void _onButtonPress() {
    setState(() {
      _isSelected = !_isSelected;
    });
    widget.game.checkWord();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: const Alignment(-1, -.5),
      child: Padding(
        padding: const EdgeInsets.only(left: 16.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal, // button color
            foregroundColor: Colors.white, // icon/text color
            shadowColor: Colors.black, // shadow color
            elevation: 5, // shadow depth
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30), // rounded corner
            ),
            padding: const EdgeInsets.all(16),
          ),
          onPressed: () => _onButtonPress(),
          child: const Icon(
            Icons.check, // using a checkmark as an example
            size: 24,
          ),
        ),
      ),
    );
  }
}
