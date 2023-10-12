import 'package:flappy_word/components/letter.dart';

class GameLetter {
  final String letter;
  final int value;

  GameLetter(this.letter) : value = Letter.letterValues[letter] ?? 0;
}
