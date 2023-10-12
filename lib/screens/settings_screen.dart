import 'package:flappy_word/enums/difficulty.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final FlappyWordGame game;
  const SettingsScreen({super.key, required this.game});

  @override
  SettingsScreenState createState() => SettingsScreenState();
}

class SettingsScreenState extends State<SettingsScreen> {
  Difficulty _selectedDifficulty = Difficulty.easy;

  @override
  void initState() {
    super.initState();
    _selectedDifficulty = widget.game.difficulty;
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          height: 300,
          width: 250,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Settings',
                style: TextStyle(
                  color: Color.fromRGBO(255, 255, 255, 1.0),
                  fontSize: 24,
                ),
              ),
              ListTile(
                title: const Text('Easy'),
                leading: Radio<Difficulty>(
                  value: Difficulty.easy,
                  groupValue: _selectedDifficulty,
                  onChanged: (Difficulty? value) {
                    setState(() {
                      _selectedDifficulty = value!;
                      widget.game.setDifficulty(_selectedDifficulty);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Medium'),
                leading: Radio<Difficulty>(
                  value: Difficulty.medium,
                  groupValue: _selectedDifficulty,
                  onChanged: (Difficulty? value) {
                    setState(() {
                      _selectedDifficulty = value!;
                      widget.game.setDifficulty(_selectedDifficulty);
                    });
                  },
                ),
              ),
              ListTile(
                title: const Text('Hard'),
                leading: Radio<Difficulty>(
                  value: Difficulty.hard,
                  groupValue: _selectedDifficulty,
                  onChanged: (Difficulty? value) {
                    setState(() {
                      _selectedDifficulty = value!;
                      widget.game.setDifficulty(_selectedDifficulty);
                    });
                  },
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.game.overlays.remove('MainMenu');
                  widget.game.overlays.add('MainMenu');
                  Navigator.of(context).pop(); // Close the settings screen
                },
                child: const Text("Back"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
