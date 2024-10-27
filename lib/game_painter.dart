import 'package:engine_3d/models/point_3d.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class GamePainter extends CustomPainter {
  final Point3D carPosition;
  final double carDirection;
  final List<Point3D> cubes;

  // Camera parameters
  double cameraX;
  double cameraY;
  double cameraZ;

  double focalLength = 550;

  double screenCenterX = 0;
  double screenCenterY = 0;

  GamePainter({
    required this.carPosition,
    required this.carDirection,
    required this.cubes,
    required this.cameraX,
    required this.cameraY,
    required this.cameraZ,
  });

  @override
  void paint(Canvas canvas, Size size) {
    screenCenterX = size.width / 2;
    screenCenterY = size.height / 2;

    _drawHorizon(canvas, size);
    drawAxes(canvas);
    drawTest(canvas, size);

    // _drawHorizon(canvas, size);
    _drawCar(canvas);
    _drawFloor(canvas);
  }

  void drawTest(Canvas canvas, Size size) {
    Point3D strPoint = Point3D(0, 0, 0);
    Point3D fisPoint = Point3D(0, 200, 200);

    Offset strPointP = project3DFromPoint(strPoint);
    Offset fisPointP = project3DFromPoint(fisPoint);

    canvas.drawLine(
      strPointP,
      fisPointP,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6.0
        ..color = Colors.orange,
    );

    // Define the four corner points of the square in 3D space
    Point3D p1 = Point3D(0, 0, 0);
    Point3D p2 = Point3D(200, 0, 200);
    Point3D p3 = Point3D(0, 200, 0);

    Offset p1P = project3DFromPoint(p1);
    Offset p2P = project3DFromPoint(p2);
    Offset p4P = project3DFromPoint(p3);

    Path path = Path()
      ..moveTo(p1P.dx, p1P.dy)
      ..lineTo(p2P.dx, p2P.dy)
      ..lineTo(p4P.dx, p4P.dy)
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..strokeWidth = 6.0
        ..color = Colors.blue.withOpacity(.3),
    );
  }

  void drawAxes(Canvas canvas) {
    final axisPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    double axisLength = 400; // Adjusted length

    Point3D xAxisEnd = Point3D(axisLength, 0, 0);
    Point3D yAxisEnd = Point3D(0, axisLength, 0);
    Point3D zAxisEnd = Point3D(0, 0, axisLength);

    Offset origin2D = _project3D(0, 0, 0);
    Offset xAxisEnd2D = _project3D(xAxisEnd.x, xAxisEnd.y, xAxisEnd.z);
    Offset yAxisEnd2D = _project3D(yAxisEnd.x, yAxisEnd.y, yAxisEnd.z);
    Offset zAxisEnd2D = _project3D(zAxisEnd.x, zAxisEnd.y, zAxisEnd.z);

    axisPaint.color = Colors.red;
    canvas.drawLine(origin2D, xAxisEnd2D, axisPaint);

    axisPaint.color = Colors.green;
    canvas.drawLine(origin2D, yAxisEnd2D, axisPaint);

    axisPaint.color = Colors.blue;
    canvas.drawLine(origin2D, zAxisEnd2D, axisPaint);
  }

  void _drawFloor(Canvas canvas) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final cube in cubes) {
      _drawCube(canvas, cube, paint, Colors.orange);
    }
  }

  void _drawCar(Canvas canvas) {
    final carPaint = Paint()..style = PaintingStyle.fill;

    double carWidth = 40;
    double carHeight = 20;
    double carLength = 60;

    List<Point3D> localVertices = [
      Point3D(carLength / 2, carHeight, -carWidth / 2), // 0: FrontLeftTop
      Point3D(carLength / 2, carHeight, carWidth / 2), // 1: FrontRightTop
      Point3D(carLength / 2, 0, -carWidth / 2), // 2: FrontLeftBottom
      Point3D(carLength / 2, 0, carWidth / 2), // 3: FrontRightBottom
      Point3D(-carLength / 2, carHeight, -carWidth / 2), // 4: BackLeftTop
      Point3D(-carLength / 2, carHeight, carWidth / 2), // 5: BackRightTop
      Point3D(-carLength / 2, 0, -carWidth / 2), // 6: BackLeftBottom
      Point3D(-carLength / 2, 0, carWidth / 2), // 7: BackRightBottom
    ];

    // Transform vertices from local car space to world space
    List<Point3D> transformedVertices = [];

    for (Point3D vertex in localVertices) {
      // Rotate around y-axis (car's orientation)
      double xRot =
          vertex.x * math.cos(carDirection) - vertex.z * math.sin(carDirection);
      double yRot = vertex.y;
      double zRot =
          vertex.x * math.sin(carDirection) + vertex.z * math.cos(carDirection);

      // Translate to world coordinates (car's position)
      double xWorld = xRot + carPosition.x;
      double yWorld = yRot + carPosition.y;
      double zWorld = zRot + carPosition.z;

      transformedVertices.add(Point3D(xWorld, yWorld, zWorld));
    }

    // Draw the cuboid representing the car
    _drawCuboid(canvas, transformedVertices, carPaint);
  }

  void _drawHorizon(Canvas canvas, Size size) {
    // Define the rectangle covering the entire canvas
    Rect rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // Calculate the position of the horizon line
    double horizonY = screenCenterY;

    // Create a linear gradient that transitions at the horizon
    Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color.fromARGB(255, 8, 77, 133),
          Colors.blue, // Sky color
          // const Color.fromARGB(255, 154, 158, 154).withOpacity(.5),
          // const Color.fromARGB(255, 105, 105, 105).withOpacity(.5),
          const Color.fromARGB(255, 72, 72, 72),
          const Color.fromARGB(255, 33, 33, 33),
        ],
        stops: [
          0.0,
          horizonY / size.height,
          horizonY / size.height,
          1.0,
        ],
      ).createShader(rect);

    // Draw the gradient on the canvas
    canvas.drawRect(rect, paint);
  }

  void _drawCube(
      Canvas canvas, Point3D position, Paint paint, Color baseColor) {
    double cubeSize = 10;

    // Define the 8 vertices of the cube in 3D space.
    List<Point3D> vertices = [
      Point3D(position.x, position.y, position.z), // 0: TopLeftFront
      Point3D(
          position.x + cubeSize, position.y, position.z), // 1: TopRightFront
      Point3D(position.x, 0, position.z), // 2: BottomLeftFront
      Point3D(position.x + cubeSize, 0, position.z), // 3: BottomRightFront
      Point3D(position.x, position.y, position.z + cubeSize), // 4: TopLeftBack
      Point3D(position.x + cubeSize, position.y,
          position.z + cubeSize), // 5: TopRightBack
      Point3D(position.x, 0, position.z + cubeSize), // 6: BottomLeftBack
      Point3D(position.x + cubeSize, 0,
          position.z + cubeSize), // 7: BottomRightBack
    ];

    // Project the 3D vertices to 2D screen space.
    List<Offset> projectedVertices = vertices.map((vertex) {
      return _project3D(vertex.x, vertex.y, vertex.z);
    }).toList();

    // Define the edges that connect the vertices to form the cube.
    List<List<int>> edges = [
      [0, 1], [1, 3], [3, 2], [2, 0], // Front face edges
      [4, 5], [5, 7], [7, 6], [6, 4], // Back face edges
      [0, 4], [1, 5], [2, 6],
      [3, 7], // Connecting edges between front and back faces
    ];

    // Set the color and width of the lines connecting the vertices.
    paint.color = Colors.blue; // You can change this to any color you like.
    paint.strokeWidth = 2.0;

    // Draw each line (edge) connecting the vertices.
    for (final edge in edges) {
      canvas.drawLine(
        projectedVertices[edge[0]],
        projectedVertices[edge[1]],
        paint,
      );
    }

    // Optionally, draw the faces of the cube with a semi-transparent fill color.
    List<List<int>> faces = [
      [0, 1, 3, 2], // Front face
      [4, 5, 7, 6], // Back face
      [0, 1, 5, 4], // Top face
      [2, 3, 7, 6], // Bottom face
      [0, 4, 6, 2], // Left face
      [1, 5, 7, 3], // Right face
    ];

    // Colors for different faces (optional)
    List<Color> faceColors = [
      baseColor.withOpacity(0.2),
      baseColor.withOpacity(0.3),
      baseColor.withOpacity(0.4),
      baseColor.withOpacity(0.5),
      baseColor.withOpacity(0.6),
      baseColor.withOpacity(0.7),
    ];

    // Draw each face (optional, if you want to fill the faces with colors).
    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final facePaint = Paint()
        ..style = PaintingStyle.fill
        ..color = faceColors[i % faceColors.length];

      final path = Path()
        ..moveTo(projectedVertices[face[0]].dx, projectedVertices[face[0]].dy)
        ..lineTo(projectedVertices[face[1]].dx, projectedVertices[face[1]].dy)
        ..lineTo(projectedVertices[face[2]].dx, projectedVertices[face[2]].dy)
        ..lineTo(projectedVertices[face[3]].dx, projectedVertices[face[3]].dy)
        ..close();

      canvas.drawPath(path, facePaint);
    }
  }

  /// Draws a cuboid given its transformed vertices.
  void _drawCuboid(
      Canvas canvas, List<Point3D> transformedVertices, Paint paint) {
    // Project the transformed vertices
    List<Offset> projectedVertices = [];

    for (Point3D vertex in transformedVertices) {
      Offset projectedPoint = _project3D(vertex.x, vertex.y, vertex.z);
      projectedVertices.add(projectedPoint);
    }

    // Define faces with indices to the vertices
    List<List<int>> faces = [
      [0, 1, 3, 2], // Front face
      [0, 2, 6, 4], // Left face
      [1, 3, 7, 5], // Right face
      [4, 5, 7, 6], // Back face
      [0, 1, 5, 4], // Top face
      [2, 3, 7, 6], // Bottom face
    ];

    // Colors for different faces
    List<Color> faceColors = [
      Colors.blue.withOpacity(0.8), // Front face (highlighted)
      Colors.red.withOpacity(0.7), // Left face
      Colors.red.withOpacity(0.6), // Right face
      Colors.red.withOpacity(0.5), // Back face
      Colors.red.withOpacity(0.4), // Top face
      Colors.red.withOpacity(0.3), // Bottom face
    ];

    // Draw each face
    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final color = faceColors[i % faceColors.length];

      final path = Path()
        ..moveTo(projectedVertices[face[0]].dx, projectedVertices[face[0]].dy)
        ..lineTo(projectedVertices[face[1]].dx, projectedVertices[face[1]].dy)
        ..lineTo(projectedVertices[face[2]].dx, projectedVertices[face[2]].dy)
        ..lineTo(projectedVertices[face[3]].dx, projectedVertices[face[3]].dy)
        ..close();

      paint.color = color;
      canvas.drawPath(path, paint);
    }
  }

  /// Projects a 3D point onto the 2D screen.
  Offset _project3D(double x, double y, double z) {
    double scale = focalLength / (cameraZ - z);

    double projectedX = (x - cameraX) * scale;
    double projectedY = (y - cameraY) * scale;

    return Offset(projectedX + screenCenterX, projectedY + screenCenterY);
  }

  Offset project3DFromPoint(Point3D point) {
    double scale = focalLength / (cameraZ - point.z);

    double projectedX = (point.x - cameraX) * scale;
    double projectedY = (point.y - cameraY) * scale;

    return Offset(projectedX + screenCenterX, projectedY + screenCenterY);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
