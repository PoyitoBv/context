/*
import 'dart:developer';

import 'package:flutter/material.dart';

import 'package:vector_math/vector_math_64.dart' as vec;
import 'dart:ui';

import 'package:rive/rive.dart' as rive;
import 'package:grain/grain.dart';

late FragmentProgram fragmentProgram;

Future<void> main() async {
  fragmentProgram =
      await FragmentProgram.fromAsset('assets/shaders/texture.frag');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final TransformationController _controller = TransformationController();

  @override
  Widget build(BuildContext context) {
    const String path =
        "https://letsenhance.io/static/8f5e523ee6b2479e26ecc91b9c25261e/1015f/MainAfter.jpg";
    const Color bg = Color.fromRGBO(219, 216, 202, 1);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Material App',
      home: Scaffold(
        backgroundColor: bg,
        body: Stack(
          children: [
            Center(
              child: GrainFiltered(
                animated: false,
                scale: 0.7,
                child: View(path: path, ctrl: _controller),
              ),
            ),
            Center(
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                ),
                height: 8,
                width: 8,
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            MapController().onBoat();
          },
        ),
      ),
    );
  }
}

class View extends StatefulWidget {
  const View({
    super.key,
    required this.path,
    required this.ctrl,
  });

  final String path;
  final TransformationController ctrl;

  @override
  State<View> createState() => _ViewState();
}

class _ViewState extends State<View> {
  late double grain;

  @override
  void initState() {
    grain = 0.7;

    super.initState();
  }

  vec.Vector2 getCenterCoordinate(Size size) {
    // Obtén el tamaño de la pantalla
    final Size screenSize = size;

    // Obtén la posición del centro de la pantalla
    final Offset screenCenter =
        Offset(screenSize.width / 2, screenSize.height / 2);

    // Obtén la matriz de transformación actual
    final Matrix4 transform = widget.ctrl.value;

    // Invertir la matriz para calcular la posición en la imagen
    final Matrix4 inverseMatrix = Matrix4.inverted(transform);

    // Transforma la posición del centro de la pantalla a coordenadas de la imagen
    final vec.Vector3 centerInImage = inverseMatrix
        .transform3(vec.Vector3(screenCenter.dx, screenCenter.dy, 0));

    return vec.Vector2(centerInImage.x, centerInImage.y);
  }

  double _updateZoomLevel() {
    // Obtener el componente de escalado de la matriz de transformación
    double scale = widget.ctrl.value.getMaxScaleOnAxis();

    // Normalizar el nivel de zoom al rango de 0 a 100
    double zoomLevel = ((scale - 0.1) / (8 - 0.1)) * 100;

    // setState(() => grain = _interpolate(zoomLevel));

    return zoomLevel;
  }

  double _interpolate(double x) {
    // Puntos conocidos
    double x0 = 0;
    double y0 = 0.7;

    double x1 = 100;
    double y1 = 0.1;

    // Fórmula de interpolación lineal
    double y = y0 + ((y1 - y0) / (x1 - x0)) * (x - x0);

    log(y.toString());
    return y;
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      transformationController: widget.ctrl,
      constrained: false,
      minScale: 0.1,
      maxScale: 8,
      onInteractionEnd: (details) {},
      onInteractionUpdate: (details) {
        final vec.Vector2 center =
            getCenterCoordinate(MediaQuery.of(context).size);
        final zoom = _updateZoomLevel();

        MapController().setMovement(center, zoom);
      },
      child: Container(
        color: Colors.transparent,
        height: 1080,
        width: 1920,
        child: CustomPaint(
            painter: WatercolorPainter(
              const Color.fromRGBO(219, 216, 202, 1),
            ),
            child:
                const Padding(padding: EdgeInsets.all(50), child: Animation())),
      ),
    );
  }
}

class Animation extends StatefulWidget {
  const Animation({
    super.key,
  });

  @override
  State<Animation> createState() => _AnimationState();
}

class _AnimationState extends State<Animation> {
  @override
  Widget build(BuildContext context) {
    return rive.RiveAnimation.asset(
      'assets/test.riv',
      // artboard: 'hola',
      onInit: MapController().onInit,
      fit: BoxFit.cover,
      stateMachines: const ['main'],
    );
  }
}

class MapController {
  static final MapController _instance = MapController._internal();

  factory MapController() => _instance;

  MapController._internal();

  // StateMachine Controller
  // late rive.StateMachineController _controller;

  rive.SMITrigger? _onBoat;
  rive.SMIInput<bool>? _zone1;
  rive.SMIInput<double>? _x;
  rive.SMIInput<double>? _y;
  rive.SMIInput<double>? _zoom;

  bool _inZone1 = false;

  void onInit(rive.Artboard art) {
    var ctrl = rive.StateMachineController.fromArtboard(art, 'main')
        as rive.StateMachineController;
    ctrl.isActive = true;
    art.addController(ctrl);

    // _controller = ctrl;

    _onBoat = ctrl.findInput<bool>('onBoat') as rive.SMITrigger;
    _zone1 = ctrl.findInput<bool>('Zone1') as rive.SMIBool;
    _x = ctrl.findInput<double>('x') as rive.SMINumber;
    _y = ctrl.findInput<double>('y') as rive.SMINumber;
    _zoom = ctrl.findInput<double>('Zoom') as rive.SMINumber;
  }

  void setMovement(vec.Vector2 point, double z) {
    _x?.value = point.x;
    _y?.value = point.y;
    _zoom?.value = z;

    _isPointInPolygon(point);
  }

  void onBoat() {
    _onBoat?.fire;
  }

  void _inZone(bool isIn) => _zone1?.value = isIn;

  void _isPointInPolygon(vec.Vector2 point) {
    List<vec.Vector2> polygon = [
      vec.Vector2(313.1064, 402.9574),
      vec.Vector2(461.0405, 586.0788),
      vec.Vector2(539.6069, 620.1756),
      vec.Vector2(682.2452, 662.3972),
      vec.Vector2(714.7558, 655.6066),
      vec.Vector2(801.1509, 626.3341),
      vec.Vector2(841.3941, 540),
      vec.Vector2(715.7771, 592.3404),
      vec.Vector2(655.0112, 503.234),
      vec.Vector2(690.075, 395.3191),
    ];

    int intersectCount = 0;

    for (int i = 0; i < polygon.length; i++) {
      vec.Vector2 v1 = polygon[i];
      vec.Vector2 v2 = polygon[(i + 1) % polygon.length];

      // Verifica si el punto está en el rango Y del borde
      if ((point.y > v1.y) != (point.y > v2.y)) {
        double xIntersection =
            (point.y - v1.y) * (v2.x - v1.x) / (v2.y - v1.y) + v1.x;
        if (point.x < xIntersection) {
          intersectCount++;
        }
      }
    }

    // Si el número de intersecciones es impar, el punto está dentro
    bool isIn = intersectCount % 2 == 1;

    if (isIn != _inZone1) {
      _inZone1 = isIn;
      _inZone(isIn);
    }
  }
}

class WatercolorPainter extends CustomPainter {
  WatercolorPainter(this.color);

  final Color color;

  final FragmentShader shader = fragmentProgram.fragmentShader();

  @override
  void paint(Canvas canvas, Size size) {
    shader.setFloat(0, size.width); // u_resolution.x
    shader.setFloat(1, size.height); // u_resolution.y
    shader.setFloat(2, color.red / 255); // uColor.R
    shader.setFloat(3, color.green / 255); // uColor.G
    shader.setFloat(4, color.blue / 255); // uColor.B
    shader.setFloat(5, 0.1); // uIntense
    shader.setFloat(6, 5.0); // uSize

    final paint = Paint()
      ..shader = shader
      ..blendMode = BlendMode.difference;

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
*/