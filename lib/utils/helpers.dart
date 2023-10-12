import 'package:flappy_word/enums/difficulty.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> saveHighScore(int score, Difficulty difficulty) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'highScore_$difficulty'; // E.g. highScore_easy or highScore_hard
  final highScore = prefs.getInt(key) ?? 0;

  if (score > highScore) {
    await prefs.setInt(key, score);
  }
}

Future<int> loadHighScore(Difficulty difficulty) async {
  final prefs = await SharedPreferences.getInstance();
  final key = 'highScore_$difficulty'; // E.g. highScore_easy or highScore_hard
  return prefs.getInt(key) ?? 0;
}
