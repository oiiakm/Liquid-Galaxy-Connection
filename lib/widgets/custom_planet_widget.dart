import 'dart:math';

import 'package:flutter/material.dart';

class CustomPlanetWidget extends CustomPainter {
  final double value;
  List<Planet> planets = [];

  CustomPlanetWidget(this.value) {
    planets
        .add(Planet(radiusFactor: 0.1, color: Colors.orange, startAngle: 0.0));
    planets.add(
        Planet(radiusFactor: 0.15, color: Colors.blue, startAngle: pi / 3));
    planets.add(
        Planet(radiusFactor: 0.2, color: Colors.red, startAngle: 2 * pi / 3));
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    for (var i = 0; i < planets.length; i++) {
      final planet = planets[i];
      final angle =
          value * 2.0 * pi * (i + 1) / planets.length + planet.startAngle;

      final orbitRadius = size.width * 0.4;

      final planetX = center.dx + orbitRadius * cos(angle);
      final planetY = center.dy + orbitRadius * sin(angle);

      final gradient = RadialGradient(
        colors: [planet.color, planet.color.withOpacity(0.5)],
        stops: const [0.0, 1.0],
      );

      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

      canvas.drawCircle(
        Offset(planetX + 10, planetY + 10),
        planet.radiusFactor * orbitRadius,
        shadowPaint,
      );

      final paint = Paint()
        ..shader = gradient.createShader(Rect.fromCircle(
          center: Offset(planetX, planetY),
          radius: planet.radiusFactor * orbitRadius,
        ))
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
          Offset(planetX, planetY), planet.radiusFactor * orbitRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class Planet {
  final double radiusFactor;
  final Color color;
  final double startAngle;

  Planet({
    required this.radiusFactor,
    required this.color,
    required this.startAngle,
  });
}

class ParallaxContainer extends StatelessWidget {
  final double xParallax;
  final double yParallax;
  final Widget child;

  const ParallaxContainer({
    Key? key,
    required this.xParallax,
    required this.yParallax,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform(
      transform: Matrix4.translationValues(xParallax * 20, yParallax * 20, 0.0),
      child: child,
    );
  }
}
