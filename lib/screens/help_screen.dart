import 'package:flutter/material.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const gradientStartColor = Colors.black;
    const gradientEndColor = Color.fromARGB(255, 255, 173, 200);
    const whiteTextColor = Colors.white;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "How to play",
          style: TextStyle(
              color: whiteTextColor, fontSize: 22, fontWeight: FontWeight.w600),
        ),
        backgroundColor: gradientStartColor,
        iconTheme: const IconThemeData(color: whiteTextColor),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [gradientStartColor, gradientStartColor, gradientEndColor],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: ListView(
            children: [
              const CustomAccordion(
                title: "Controls",
                content: '''
Tap to jump.''',
              ),
              const CustomAccordion(
                title: "Objective",
                content: '''Build words as you navigate through the game.

Avoid any obstacles.

Press the button to submit your word. Remember, incorrect submissions result in a penalty!''',
              ),
              const CustomAccordion(
                title: "Scoring",
                content:
                    '''Collecting letters give you the amount of points respective to the letter. 
                    
i.e Collecting a C gives you 3 points, Z is 10, etc..
                    
You can carry up to 10 letters at a time. Collecting 11 will result in a penalty to your score!

Aim to achieve the highest score possible.''',
              ),
              const CustomAccordion(
                title: "Bonus",
                content:
                    '''Words with the letter count between 5 and 7 results in double points!

Words with more than 7 letters are triple points!''',
              ),
              const SizedBox(height: 50),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: whiteTextColor,
                    foregroundColor: gradientStartColor,
                    minimumSize: const Size(150, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text("Got it!", style: TextStyle(fontSize: 20)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomAccordion extends StatefulWidget {
  final String title;
  final String content;

  const CustomAccordion({
    required this.title,
    required this.content,
    Key? key,
  }) : super(key: key);

  @override
  CustomAccordionState createState() => CustomAccordionState();
}

class CustomAccordionState extends State<CustomAccordion> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      trailing: Icon(
        _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
        color: Colors.white,
        size: 28.0,
      ),
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
          child: Text(
            widget.content,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }
}
