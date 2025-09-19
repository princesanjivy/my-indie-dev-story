import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:super_bullet_list/bullet_list.dart';

void main() {
  runApp(const PlatformerTalk());
}

class FixedWidthScaffold extends StatelessWidget {
  final Widget child;
  static const double targetWidth = 1600;
  static const double targetHeight = 600;
  const FixedWidthScaffold({super.key, required this.child});
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / targetWidth;
        return defaultTargetPlatform == TargetPlatform.android
            ? child
            : Container(
                color: Colors.white70,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Need to do properly
                    SizedBox(
                      height: 100,
                      child: Scaffold(
                        backgroundColor: Colors.transparent,
                        body: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "My indie dev story: ",
                              style: GoogleFonts.hennyPenny(
                                fontSize: 48,
                                color: Colors.green,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              "Building apps, games & side projects with Flutter!",
                              style: GoogleFonts.hennyPenny(
                                fontSize: 26,
                                color: Colors.green,
                              ),
                            ),
                            // Text(
                            //   "Building apps, games & side projects with Flutter!",
                            // ),
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: Transform.scale(
                        scale: scale.clamp(0.1, 1.0),
                        alignment: Alignment.topCenter,
                        child: Container(
                          padding: EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            color: Colors.black,
                          ),
                          child: SizedBox(
                            width: targetWidth,
                            height: targetHeight,
                            child: child,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
      },
    );
  }
}

class PlatformerTalk extends StatelessWidget {
  const PlatformerTalk({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return FixedWidthScaffold(child: child!);
      },
      theme: ThemeData(
        useMaterial3: false,
        textTheme: GoogleFonts.kuraleTextTheme().copyWith(),
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(body: GameScreen()),
    );
  }
}

class Checkpoint {
  Rect rect;
  String text;

  Checkpoint(this.rect, this.text);
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen>
    with SingleTickerProviderStateMixin {
  double playerX = 50;
  double playerY = 300;

  final double playerW = 120; // player width
  final double playerH = 171; // player height

  double velocityX = 0; // horizontal velocity
  double velocityY = -10; // vertical velocity

  bool isOnGround = true;
  bool showDialog = false;
  bool flip = false;

  Checkpoint? activeCheckpoint;

  final double groundY = 500;

  final List<Rect> platforms = [
    const Rect.fromLTWH(345, 284, 150, 30),
    const Rect.fromLTWH(588, 190, 150, 30),
    const Rect.fromLTWH(800, 346, 150, 30),
    const Rect.fromLTWH(1096, 411, 150, 30),
    const Rect.fromLTWH(1255, 301, 150, 30),
    const Rect.fromLTWH(1397, 175, 150, 30),
  ];

  final Map<String, Rect> checkpoints = {
    "idea": const Rect.fromLTWH(207, 426, 60, 60),
    "flutter": const Rect.fromLTWH(388, 221, 43, 50),
    "star": const Rect.fromLTWH(603, 381, 60, 60),
    "me": const Rect.fromLTWH(633, 122, 60, 60),
    "tools": const Rect.fromLTWH(850, 289, 50, 50),
    "cart": const Rect.fromLTWH(1133, 344, 60, 60),
    "phone": const Rect.fromLTWH(1442, 100, 60, 60),
  };

  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller =
        AnimationController(vsync: this, duration: const Duration(days: 1))
          ..addListener(_update)
          ..forward();
  }

  void _update() {
    setState(() {
      // Gravity
      velocityY += 0.5;
      playerY += velocityY;

      playerX += velocityX;

      // Keep inside screen bounds
      if (playerX < 0) playerX = 0;
      if (playerX > 1600) playerX = 1600;

      // Ground collision
      if (playerY + playerH >= groundY) {
        playerY = groundY - playerH;
        velocityY = 0;
        isOnGround = true;
      }

      // Platform collision
      for (var p in platforms) {
        if (playerX + playerW > p.left &&
            playerX < p.right &&
            playerY + playerH >= p.top &&
            playerY + playerH <= p.top + 10 &&
            velocityY >= 0) {
          playerY = p.top - playerH; // stand on top of platform
          velocityY = 0;
          isOnGround = true;
        }
      }

      // Checkpoint collision
      activeCheckpoint = null;
      // if (activeCheckpoint == null) {
      //   setState(() => showDialog = false);
      // }

      for (var c in checkpoints.keys) {
        Rect r = checkpoints[c]!;
        if (Rect.fromLTWH(playerX, playerY, playerW, playerH).overlaps(r)) {
          activeCheckpoint = Checkpoint(r, c);
        }
      }
    });
  }

  void _handleKey(RawKeyEvent e) {
    if (e is RawKeyDownEvent) {
      if (e.logicalKey.keyLabel == "Arrow Left") {
        velocityX = -10;
        showDialog = false;
        flip = true;
        setState(() {});
      }
      if (e.logicalKey.keyLabel == "Arrow Right") {
        velocityX = 10;
        showDialog = false;
        flip = false;
        setState(() {});
      }
      if (e.logicalKey.keyLabel == "Arrow Up") {
        if (isOnGround) {
          velocityY = -15; // jump strength
          isOnGround = false;
        }
      }
      if (e.logicalKey.keyLabel == ' ') {
        if (activeCheckpoint != null) {
          setState(() => showDialog = !showDialog);
        }
      }
    }

    if (e is RawKeyUpEvent) {
      if (e.logicalKey.keyLabel == "Arrow Left" ||
          e.logicalKey.keyLabel == "Arrow Right") {
        velocityX = 0; // stop when key is released
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RawKeyboardListener(
      autofocus: true,
      focusNode: FocusNode(),
      onKey: _handleKey,
      child: Stack(
        children: [
          // bg
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0xFFaccbee), Color(0xFFe7f0fd)],
              ),
            ),
          ),
          // ground
          Positioned(
            left: 0,
            right: 0,
            top: groundY,
            height: 100,
            child: Container(color: Colors.brown),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: groundY,
            height: 20,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFF013220),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 2),
                    blurRadius: 2,
                    color: Colors.black.withOpacity(0.5),
                  ),
                ],
              ),
            ),
          ),
          // platforms
          for (var p in platforms)
            Positioned(
              left: p.left,
              top: p.top,
              width: p.width,
              height: p.height,
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFFFF4D0),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(2, 2),
                      blurRadius: 2,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
            ),
          // yellows
          for (var c in checkpoints.keys)
            Positioned(
              left: checkpoints[c]!.left,
              top: checkpoints[c]!.top,
              width: checkpoints[c]!.width,
              height: checkpoints[c]!.height,
              child: Image.asset(
                "assets/images/$c.png",
                width: checkpoints[c]!.width,
                height: checkpoints[c]!.height,
              ),
            ),
          // player
          Positioned(
            left: playerX,
            top: playerY,
            width: playerW,
            height: playerH,
            child: Transform.flip(
              flipX: flip,
              child: Image.asset(
                "assets/images/prince.png",
                fit: BoxFit.fitHeight,
                width: playerW,
                height: playerH,
              ),
            ),
          ),

          if (showDialog && activeCheckpoint != null)
            Container(
              width: 1600,
              height: 600,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white70),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      border: BoxBorder.all(color: Colors.black),
                    ),
                    padding: EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          slidesTitleText[activeCheckpoint!.text]!,
                          style: GoogleFonts.hennyPenny(
                            fontSize: 48,
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        SuperBulletList(
                          isOrdered: true,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          gap: 8,
                          textStyle: TextStyle(fontSize: 32),
                          items: slidesContentText[activeCheckpoint!.text]!,
                        ),
                        const SizedBox(height: 12),
                        // ElevatedButton(
                        //   onPressed: () => setState(() => showDialog = false),
                        //   child: const Text("Close"),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Map<String, List<Widget>> slidesContentText = {
    "idea": [
      ItemText("Backend engineer by profession, Indie dev by passion"),
      ItemText("How I started app development?"),
      ItemText("My first app on the PlayStore"),
    ],
    "flutter": [
      ItemText("The tech stack I used before Flutter"),
      ItemText("How I get to know Flutter"),
      ItemText("What I like about Flutter"),
    ],
    "me": [
      ItemText("Designs"),
      ItemText("Start with small prototypes"),
      ItemText("Launching a beta version"),
    ],
    "tools": [
      ItemText("IDEs, Version Control"),
      ItemText("Using AI as a coding buddy"),
    ],
    "cart": [
      ItemText("PlayStore, App Store and alternatives"),
      ItemText("Setting up pipelines"),
      ItemText("Choosing the right backend infra"),
      ItemText("Monetization & Promotions"),
    ],
    "phone": [ItemText("Demo")],
    "star": [ItemText("Thank You!!!")],
  };

  Map<String, String> slidesTitleText = {
    "idea": "Intro",
    "flutter": "Why Flutter?",
    "me": "From idea to app dev",
    "tools": "Tools & AI",
    "cart": "Getting apps to production",
    "phone": "My creations",
    "star": "Ask me anything",
  };
}

class ItemText extends StatelessWidget {
  final String text;
  const ItemText(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Text(text, style: TextStyle(fontSize: 28));
  }
}
