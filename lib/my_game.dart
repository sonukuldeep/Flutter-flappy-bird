import 'dart:async';

import 'package:flutter/material.dart';
import 'package:game/barrier.dart';
import 'package:game/bird.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyGame extends StatefulWidget {
  const MyGame({super.key});

  @override
  State<MyGame> createState() => _MyGameState();
}

class _MyGameState extends State<MyGame> {
  static double birdY = 0;
  static int jumps = 0;
  static int best = 0;
  double initialPos = birdY;
  double height = 0;
  double time = 0;
  double gravity = -4.9;
  double velocity = 3.5;
  double birdWidth = 0.2;
  double birdheight = 0.2;

  bool gameHasStated = false;

  static List<double> barrierX = [2, 2 + 1.5];
  static double barrierWidth = 0.5;
  List<List<double>> barrierHeight = [
    [0.6, 0.4],
    [0.4, 0.6],
  ];
  void startGame() {
    gameHasStated = true;
    loadBestScore();
    Timer.periodic(const Duration(milliseconds: 10), (timer) {
      height = gravity * time * time + velocity * time;

      setState(() {
        birdY = initialPos - height;
      });

      if (birdDead()) {
        timer.cancel();
        _showDialog();
      }
      moveMap();

      time += 0.01;
    });
  }

  void moveMap() {
    for (int i = 0; i < barrierX.length; i++) {
      setState(() {
        barrierX[i] -= 0.005;
      });

      if (barrierX[i] < -1.5) {
        barrierX[i] += 3;
      }
    }
  }

  void _showDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.brown,
            title: const Center(
              child: Text(
                'Game Over!',
                style: TextStyle(color: Colors.white),
              ),
            ),
            actions: [
              GestureDetector(
                  onTap: restartGame,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: Container(
                      padding: const EdgeInsets.all(7),
                      color: Colors.white,
                      child: const Text(
                        "Play again",
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  ))
            ],
          );
        });
  }

  bool birdDead() {
    if (birdY < -1 || birdY > 1) {
      return true;
    }
    for (int i = 0; i < barrierX.length; i++) {
      if (barrierX[i] <= birdWidth &&
          barrierX[i] + barrierWidth >= -birdWidth &&
          (birdY <= -1 + barrierHeight[i][0] ||
              birdY + birdheight >= 1 - barrierHeight[i][1])) {
        return true;
      }
    }
    return false;
  }

  void jump() {
    setState(() {
      time = 0;
      jumps++;
      initialPos = birdY;
    });
  }

  void restartGame() {
    Navigator.pop(context);
    setState(() {
      birdY = 0;
      gameHasStated = false;
      time = 0;
      barrierX = [2, 2 + 1.5];
      initialPos = birdY;
      if (jumps > best) {
        saveBestScore(jumps);
      }
      jumps = 0;
    });
  }

  void loadBestScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      best = prefs.getInt('best') ?? 0;
    });
  }

  void saveBestScore(int score) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('best', score);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: gameHasStated ? jump : startGame,
      child: Scaffold(
        body: Column(
          children: [
            Expanded(
              flex: 3,
              child: Container(
                color: Colors.blue,
                child: Center(
                  child: Stack(
                    children: [
                      MyBird(
                          birdY: birdY,
                          birdHeight: birdheight,
                          birdWidth: birdWidth),
                      Container(
                        alignment: const Alignment(0, -0.5),
                        child: Text(
                          gameHasStated ? '' : "TAP TP PLAY",
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                        ),
                      ),
                      Barriers(
                        isThisBottomBarrier: false,
                        barrierX: barrierX[0],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][0],
                      ),
                      Barriers(
                        isThisBottomBarrier: true,
                        barrierX: barrierX[0],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[0][1],
                      ),
                      Barriers(
                        isThisBottomBarrier: false,
                        barrierX: barrierX[1],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][0],
                      ),
                      Barriers(
                        isThisBottomBarrier: true,
                        barrierX: barrierX[1],
                        barrierWidth: barrierWidth,
                        barrierHeight: barrierHeight[1][1],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$jumps",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Score",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "$best",
                          style: const TextStyle(color: Colors.white),
                        ),
                        const Text(
                          "Best",
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
