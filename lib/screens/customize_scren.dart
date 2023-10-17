import 'package:flame/components.dart';
import 'package:flame/widgets.dart';
import 'package:flappy_word/models/character_variation.dart';
import 'package:flappy_word/models/game_character.dart';
import 'package:flappy_word/screens/game_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CustomListTile extends StatelessWidget {
  final GameCharacter character;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomListTile({
    Key? key,
    required this.character,
    this.isSelected = false,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blueAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(10), // rounded corners
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            // You can add character image here

            const SizedBox(width: 10),
            Text(
              character.name,
              style: GoogleFonts.aBeeZee(
                  textStyle: TextStyle(
                fontSize: 30,
                color: isSelected ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
              )),
            ),
            // You can add more widgets here depending on your design
          ],
        ),
      ),
    );
  }
}

class CustomizeScreen extends StatefulWidget {
  const CustomizeScreen({super.key, required this.game});
  final FlappyWordGame game;

  @override
  CustomizeScreenState createState() => CustomizeScreenState();
}

class CustomizeScreenState extends State<CustomizeScreen> {
  late List<GameCharacter> characters;
  GameCharacter? selectedCharacter;
  CharacterVariation? selectedVariation;
  SpriteAnimation? selectedVariationAnimation;

  @override
  void initState() {
    super.initState();
    _loadSelectedCharacterAndVariation();
    characters = [
      GameCharacter(name: "Devilbird", variations: [
        CharacterVariation(
            imagePath: "devilbirdonesheet.png",
            spriteAmount: 8,
            displayPath: 'devilbirdone.png',
            isLocked: false),
        CharacterVariation(
            imagePath: "devilbirdtwosheet.png",
            spriteAmount: 7,
            stepTime: .08,
            displayPath: 'devilbirdtwo.png',
            isLocked: false),
      ]),
      GameCharacter(name: "DragonAlien", variations: [
        CharacterVariation(
            imagePath: "dragonalienonesheet.png",
            displayPath: 'dragonalienone.png',
            stepTime: .05,
            isLocked: false),
        CharacterVariation(
            imagePath: "dragonalientwosheet.png",
            displayPath: 'dragonalientwo.png',
            stepTime: .05,
            isLocked: false),
      ]),
      GameCharacter(name: "Classic Bird", variations: [
        CharacterVariation(
            imagePath: "classicbirdonesheet.png",
            spriteAmount: 8,
            size: 80,
            displayPath: 'classicbirdone.png',
            isLocked: false),
        CharacterVariation(
            imagePath: "classicbirdtwosheet.png",
            size: 80,
            displayPath: 'classicbirdtwo.png',
            isLocked: false),
        CharacterVariation(
            spriteAmount: 8,
            imagePath: "classicbirdthreesheet.png",
            size: 80,
            displayPath: 'classicbirdthree.png',
            isLocked: false),
      ]),
    ];
  }

  void _selectVariation(CharacterVariation variation) async {
    if (!variation.isLocked) {
      setState(() {
        selectedVariation = variation;
      });

      widget.game.changeCharacter(selectedCharacter, selectedVariation);
    }
  }

  Widget spriteToWidget(FlappyWordGame game, String imagePath,
      [Vector2? size]) {
    final sprite = Sprite(game.images.fromCache(imagePath));
    return SpriteWidget(sprite: sprite, srcSize: size);
  }

  void _loadSelectedCharacterAndVariation() async {
    final prefs = await SharedPreferences.getInstance();
    final characterName = prefs.getString('selectedCharacter');
    final variationPath = prefs.getString('selectedVariation');

    if (characterName != null && variationPath != null) {
      final character =
          characters.firstWhere((character) => character.name == characterName);

      final variation = character.variations
          .firstWhere((variation) => variation.imagePath == variationPath);
      setState(() {
        selectedCharacter = character;
        selectedVariation = variation;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black, // A dark theme for the game
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Header for character selection
              Text(
                "Choose Your Character",
                style: GoogleFonts.aBeeZee(
                    textStyle: const TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                )),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: characters.length,
                  itemBuilder: (context, index) {
                    final character = characters[index];
                    return CustomListTile(
                      character: character,
                      isSelected: selectedCharacter == character,
                      onTap: () {
                        setState(() {
                          selectedCharacter = character;
                        });
                      },
                    );
                  },
                ),
              ),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text("Let's Fly!",
                      style: TextStyle(fontSize: 20, color: Colors.black)),
                ),
              ),
              const SizedBox(height: 10),
              if (selectedCharacter != null)
                Column(
                  children: [
                    // Header for variation selection
                    const Text(
                      "Choose Variation",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8, // Space between variations
                      children: selectedCharacter!.variations.map((variation) {
                        return GestureDetector(
                          onTap: () => _selectVariation(variation),
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: selectedVariation == variation
                                    ? Colors.blueAccent
                                    : Colors
                                        .transparent, // Highlight the selected variation
                                width: 2,
                              ),
                              boxShadow: selectedVariation == variation
                                  ? [
                                      BoxShadow(
                                        color:
                                            Colors.blueAccent.withOpacity(0.5),
                                        spreadRadius: 3,
                                        blurRadius: 5,
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Opacity(
                              opacity: variation.isLocked
                                  ? 0.5
                                  : 1.0, // Dim if locked
                              child: spriteToWidget(
                                widget.game,
                                variation.displayPath,
                                Vector2(100, 100),
                              ), // Optionally specify the size
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                )
            ],
          ),
        ),
      ),
    );
  }
}
