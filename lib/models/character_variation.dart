class CharacterVariation {
  String imagePath;
  bool isLocked;
  String displayPath;
  double stepTime;
  int spriteAmount;
  double size;

  CharacterVariation(
      {required this.imagePath,
      required this.displayPath,
      this.size = 100,
      this.stepTime = .1,
      this.spriteAmount = 2,
      this.isLocked = true});
}
