import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GameOver extends StatefulWidget {
  final FlappyWordGame game;
  const GameOver({Key? key, required this.game}) : super(key: key);

  @override
  GameOverState createState() => GameOverState();
}

class GameOverState extends State<GameOver> {
  Future<int?>? highScoreFuture;

  @override
  void initState() {
    super.initState();
    highScoreFuture = _getHighScore();
  }

  Future<int?> _getHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    int? highScore = prefs.getInt('highScore');
    if (widget.game.score > (highScore ?? 0)) {
      await prefs.setInt('highScore', widget.game.score);
      highScore = widget.game.score;
    }
    return highScore;
  }

  @override
  Widget build(BuildContext context) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 350, // Adjust height to fit more contents
          width: 300,
          decoration: const BoxDecoration(
            color: blackTextColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Game Over',
                style: TextStyle(
                  color: whiteTextColor,
                  fontSize: 24,
                ),
              ),
              const SizedBox(height: 20),
              FutureBuilder<int?>(
                future: highScoreFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    String message = "Score: ${widget.game.score}";
                    if (snapshot.data == widget.game.score) {
                      message += "\nNew High Score!";
                    }
                    return Text(
                      message,
                      style: const TextStyle(
                        color: whiteTextColor,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    );
                  }
                  return const CircularProgressIndicator();
                },
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    widget.game.reset();
                    widget.game.overlays.remove('GameOver');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Play Again',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 75,
                child: ElevatedButton(
                  onPressed: () {
                    widget.game.resetMain();
                    widget.game.overlays.remove('GameOver');
                    widget.game.overlays.add('MainMenu');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                  ),
                  child: const Text(
                    'Main Menu',
                    style: TextStyle(
                      fontSize: 28.0,
                      color: blackTextColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
