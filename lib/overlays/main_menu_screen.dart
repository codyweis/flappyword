import 'package:flappy_word/screens/game_screen.dart';
import 'package:flappy_word/screens/help_screen.dart';
import 'package:flappy_word/screens/settings_screen.dart';
import 'package:flappy_word/utils/helpers.dart';
import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  final FlappyWordGame game;

  const MainMenu({Key? key, required this.game}) : super(key: key);

  @override
  MainMenuState createState() => MainMenuState();
}

class MainMenuState extends State<MainMenu> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<int>(
      future: loadHighScore(widget.game.difficulty),
      builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return _buildMainMenuContent(snapshot.data ?? 0);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return _buildErrorContent();
        }
      },
    );
  }

  Widget _buildMainMenuContent(int highScore) {
    return Stack(
      children: [
        Center(child: _buildMenuContainer(highScore)),
        _buildHelpButton()
      ],
    );
  }

  Widget _buildMenuContainer(int highScore) {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);
    const titleStyle = TextStyle(color: whiteTextColor, fontSize: 24);
    const scoreStyle = TextStyle(color: whiteTextColor, fontSize: 18);
    const infoStyle = TextStyle(color: whiteTextColor, fontSize: 16);

    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(10.0),
        height: 400,
        width: 300,
        decoration: const BoxDecoration(
          color: blackTextColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Flappy Word', style: titleStyle),
            const SizedBox(height: 20),
            Text('High Score: $highScore', style: scoreStyle),
            const SizedBox(height: 20),
            _buildPlayButton(),
            _buildIconButtonRow(),
            const SizedBox(height: 10),
            const Text(
              '''

Tap to jump!

Collect letters to build words for points, must be at least 3 letters to submit a word!''',
              textAlign: TextAlign.center,
              style: infoStyle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayButton() {
    const blackTextColor = Color.fromRGBO(0, 0, 0, 1.0);
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return SizedBox(
      width: 200,
      height: 75,
      child: ElevatedButton(
        onPressed: () {
          widget.game.playGame();
        },
        style: ElevatedButton.styleFrom(backgroundColor: whiteTextColor),
        child: const Text(
          'Play',
          style: TextStyle(fontSize: 40.0, color: blackTextColor),
        ),
      ),
    );
  }

  Widget _buildIconButtonRow() {
    const whiteTextColor = Color.fromRGBO(255, 255, 255, 1.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          icon: const Icon(Icons.settings, color: whiteTextColor, size: 40.0),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(game: widget.game),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.shop, color: whiteTextColor, size: 40.0),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(game: widget.game),
              ),
            );
          },
        ),
        IconButton(
          icon: const Icon(Icons.brush, color: whiteTextColor, size: 40.0),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SettingsScreen(game: widget.game),
              ),
            );
          },
        ),
        // ... Other Icons (shop, brush)
      ],
    );
  }

  Widget _buildHelpButton() {
    const whiteTextColor = Colors.black;

    return Positioned(
      top: 10,
      right: 10,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            // Navigate to the help screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const HelpScreen(),
              ),
            );
          },
          customBorder: const CircleBorder(),
          child: const Center(
            child: Icon(
              Icons.help_outline,
              color: whiteTextColor,
              size: 60.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Failed to load high score'),
          ElevatedButton(
            onPressed: () {
              setState(() {}); // Trigger a rebuild to attempt loading again.
            },
            child: const Text('Retry'),
          )
        ],
      ),
    );
  }
}
