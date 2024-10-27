import 'dart:async';

import 'package:engine_3d/game_painter.dart';
import 'package:engine_3d/models/point_3d.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

class Car3DGame extends StatefulWidget {
  @override
  _Car3DGameState createState() => _Car3DGameState();
}

class _Car3DGameState extends State<Car3DGame> {
  // Car's position and direction
  double carX = 0;
  double carY = 0; // Fixed height
  double carZ = 0; // Initial depth
  double carDirection = 0; // Car's rotation in radians

  // Input handling
  final FocusNode _focusNode = FocusNode();
  final Set<LogicalKeyboardKey> _keysPressed = {};

  // Game loop
  late Timer _timer;
  late DateTime _lastUpdateTime;

  // List of cubes in the scene
  List<Point3D> cubes = [];

  @override
  void initState() {
    super.initState();
    _generateFloorCubes();

    _lastUpdateTime = DateTime.now();
    _timer = Timer.periodic(const Duration(milliseconds: 16), (Timer t) => _update());
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _timer.cancel();
    super.dispose();
  }

  void _generateFloorCubes() {
    for (int i = -3; i <= 3; i++) {
      for (int j = -3; j <= 3; j++) {
        double randomHeight = math.Random().nextDouble() * 50 + 20;
        cubes.add(Point3D(i * 120.0, randomHeight, j * 120.0));
      }
    }
  }

  /// Handles keyboard events to track which keys are pressed.
  void _handleKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      _keysPressed.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _keysPressed.remove(event.logicalKey);
    }
  }

  /// Updates the game state, called periodically by the timer.
  void _update() {
    DateTime now = DateTime.now();
    double deltaTime = now.difference(_lastUpdateTime).inMilliseconds / 1000.0;
    _lastUpdateTime = now;

    if (_keysPressed.isNotEmpty) {
      setState(() {
        _processInput(deltaTime);
      });
    }
  }

  /// Processes user input to update the car's position and orientation.
  void _processInput(double deltaTime) {
    double moveSpeed = 100.0; // Units per second
    double rotationSpeed = 2.0; // Radians per second

    if (_keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      // Move forward in the direction the car is facing
      carX += moveSpeed * deltaTime * math.cos(carDirection);
      carZ += moveSpeed * deltaTime * math.sin(carDirection);
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      // Move backward
      carX -= moveSpeed * deltaTime * math.cos(carDirection);
      carZ -= moveSpeed * deltaTime * math.sin(carDirection);
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      // Rotate left
      carDirection -= rotationSpeed * deltaTime;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      // Rotate right
      carDirection += rotationSpeed * deltaTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _handleKeyEvent,
      child: Scaffold(
        body: Stack(
          children: [
            CustomPaint(
              size: Size.infinite,
              painter: GamePainter(
                carPosition: Point3D(carX, carY, carZ),
                carDirection: carDirection,
                cubes: cubes,
                cameraX: carX,
                cameraY: 300,
                cameraZ: -800 + carZ,
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: IconButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                  )),
            )
          ],
        ),
      ),
    );
  }
}
