import 'package:flutter/material.dart';

import 'package:context/paper_draw.dart';

class CustomCard extends StatelessWidget {
  CustomCard({
    super.key,
    required this.child,
    this.size,
    bool cutLeft = false,
    bool cutBottom = false,
    bool cutRight = false,
    bool cutTop = false,
  }) : config = PaperConfig(cutLeft, cutBottom, cutRight, cutTop);

  final Widget child;
  final Size? size;

  final PaperConfig config;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: LayoutBuilder(
        builder: (context, constraints) {
          config.initialize(
              size ?? Size(constraints.maxWidth, constraints.maxHeight));

          return CustomPaint(
            painter: _CardShadow(config),
            child: ClipPath(
              clipper: _CardClipper(config),
              child: config.ready
                  ? CustomPaint(
                      isComplex: true,
                      painter: _CardPainter(config),
                      child: Center(child: child),
                    )
                  : const SizedBox.shrink(),
            ),
          );
        },
      ),
    );
  }
}

class _CardClipper extends CustomClipper<Path> {
  _CardClipper(this.config);

  final PaperConfig config;

  @override
  Path getClip(Size size) {
    return config.getPath;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class _CardPainter extends CustomPainter {
  _CardPainter(this.config);

  final PaperConfig config;

  int times = 0;

  @override
  void paint(Canvas canvas, Size size) {
    // const Color textureColor = Color.fromARGB(255, 162, 145, 77);
    // const Color textureCutedColor = Color.fromARGB(255, 255, 255, 255);
    const Color bg = Color.fromRGBO(196, 171, 152, 1);
    // const Color bg = Color.fromRGBO(211, 186, 166, 1);

    final paintBG = Paint()
      ..color = bg
      ..style = PaintingStyle.fill;

    final interBorder = Paint()
      ..color = const Color.fromARGB(84, 74, 48, 1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 15;
    final specificBorder = Paint()
      ..color = const Color.fromARGB(118, 74, 48, 1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;
    final internShadow = Paint()
      ..color = const Color.fromARGB(76, 74, 48, 1)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 40;

    final Path intShadow = config.randomShadow;

    // Pintamos en el Canvas
    canvas.drawPath(config.getPath, paintBG);

    canvas.drawPath(intShadow, interBorder);
    canvas.drawPath(intShadow, specificBorder);
    canvas.drawPath(intShadow, internShadow);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _CardShadow extends CustomPainter {
  _CardShadow(this.config);

  final PaperConfig config;

  @override
  void paint(Canvas canvas, Size size) {
    const Color cutedBG = Color.fromARGB(255, 240, 240, 240);

    final paintCuted = Paint()
      ..color = cutedBG
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    final blurPaint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, .5)
      ..color = cutedBG
      ..style = PaintingStyle.stroke;

    //* ========= Draw Shadow
    canvas.drawPath(config.getPath, shadowPaint);

    //* ========= Draw Cutted Border's
    for (final cutedPath in config.getCutedSides) {
      if (cutedPath == null) continue;

      canvas.drawPath(cutedPath, paintCuted);
      canvas.drawPath(cutedPath, blurPaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}



// //!! TESTTT

//     Random rnd = Random();

//     final Paint paaai = Paint()
//       ..color = Colors.blue
//       ..style = PaintingStyle.fill;

//     int numShapes = 10; // Número de formas a dibujar
//     Path passs = Path();

//     for (int i = 0; i < numShapes; i++) {
//       print(i);
//       // Generar un tamaño aleatorio para la figura
//       double radius = rnd.nextDouble() * 40 + 10;

//       // Generar una posición aleatoria en el canvas
//       Offset center = Offset(
//         rnd.nextDouble() * size.width,
//         rnd.nextDouble() * size.height,
//       );

//       // Dibujar la figura en el canvas
//       passs = _generateAbstractShape(center, radius);
//       canvas.drawPath(passs, interBorder);
//     }

//     //!! TESTTT


// Path _generateAbstractShape(Offset center, double radius) {
//   Random rnd = Random();

//   int numPoints = rnd.nextInt(5) + 3; // Número de puntos (3 a 7)

//   Path path = Path();
//   double angleStep = 2 * pi / numPoints;

//   for (int i = 0; i < numPoints; i++) {
//     double angle = i * angleStep;
//     double pointRadius = radius * (rnd.nextDouble() * 0.5 + 0.5);
//     double x = center.dx + cos(angle) * pointRadius;
//     double y = center.dy + sin(angle) * pointRadius;

//     if (i == 0) {
//       path.moveTo(x, y);
//     } else {
//       path.lineTo(x, y);
//     }
//   }

//   path.close();
//   return path;
// }
