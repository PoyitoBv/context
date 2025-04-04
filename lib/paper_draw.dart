import 'dart:math';

import 'package:flutter/material.dart' show Size, Path;

import 'package:vector_math/vector_math.dart' as vec;

class PaperConfig {
  PaperConfig(
    this._left,
    this._bottom,
    this._right,
    this._top,
  );

  final bool _left;
  final bool _right;
  final bool _bottom;
  final bool _top;

  List<vec.Vector2> _leftVecs = [];
  List<vec.Vector2> _bottomVecs = [];
  List<vec.Vector2> _rightVecs = [];
  List<vec.Vector2> _topVecs = [];

  late Path _paperPath;
  late Path _randomShadow;

  Path? _leftCut;
  Path? _bottomCut;
  Path? _rightCut;
  Path? _topCut;

  bool get isleftCut => _leftCut != null;
  bool get isbottomCut => _bottomCut != null;
  bool get isrightCut => _rightCut != null;
  bool get istopCut => _topCut != null;

  bool ready = false;
  Path get getPath => _paperPath;

  List<vec.Vector2> get getVectorPath =>
      [..._leftVecs, ..._bottomVecs, ..._rightVecs, ..._topVecs];

  List<Path?> get getCutedSides => [_leftCut, _bottomCut, _rightCut, _topCut];

  Path get randomShadow => _randomShadow;

  void initialize(Size size) {
    if (ready) return;

    _generateSides(size);
  }

  void _generateSides(Size size) {
    //* ========== Initial Generation
    final left = _createSide(_left, 0, size.height);
    final bottom = _createSide(_bottom, left.last.y, size.width);
    final right = _createSide(_right, size.height, 0);
    final top = _createSide(_top, size.width, 0);

    //* ========== Set Normalized Values
    _leftVecs = left.map((e) => vec.Vector2(e.y, e.x)).toList();
    _bottomVecs =
        bottom.map((e) => vec.Vector2(e.x, size.height - e.y)).toList();
    _rightVecs = right.map((e) => vec.Vector2(size.width - e.y, e.x)).toList();
    _topVecs = top.map((e) => vec.Vector2(e.x, e.y)).toList();

    //* ========== Generate Principal Path's
    _createPaperPath(size);
    _createInterShadow(size);

    //* ========== Generate Cuted Sides

    // -- Left Cuted Side
    if (_left) {
      final cutPath = _drawCuted(left.reversed);

      final path = Path();

      path.moveTo(10 + left.first.y, left.first.x);

      for (final point in left) {
        path.lineTo(10 + point.y, point.x);
      }

      for (final point in cutPath) {
        path.lineTo(-2 + point.y, point.x);
      }

      path.close();

      _leftCut = path;
    }

    // -- Bottom Cuted Side
    if (_bottom) {
      final cutPath = _drawCuted(bottom.reversed);

      final path = Path();
      path.moveTo(bottom.first.x, (size.height - 10) - bottom.first.y);

      for (final point in bottom) {
        path.lineTo(point.x, (size.height - 10) - point.y);
      }

      for (final point in cutPath) {
        path.lineTo(point.x, (size.height + 2) - point.y);
      }

      path.close();

      _bottomCut = path;
    }

    // -- Right Cuted Side
    if (_right) {
      final cutPath = _drawCuted(right.reversed);

      final path = Path();
      path.moveTo((size.width - 10) - right.first.y, right.first.x);

      for (final point in right) {
        path.lineTo((size.width - 10) - point.y, point.x);
      }

      for (final point in cutPath) {
        path.lineTo((size.width + 2) - point.y, point.x);
      }

      path.close();
      _rightCut = path;
    }

    // -- Top Cuted Side
    if (_top) {
      final cutPath = _drawCuted(top.reversed);

      final path = Path();
      path.moveTo(top.first.x, 10 + top.first.y);

      for (final point in top) {
        path.lineTo(point.x, 10 + point.y);
      }

      for (final point in cutPath) {
        path.lineTo(point.x, -2 + point.y);
      }

      path.close();
      _topCut = path;
    }

    ready = true;
  }

  List<vec.Vector2> _createSide(bool side, double initialR, double finalR) {
    return side ? _cuted(initialR, finalR) : _basic(initialR, finalR);
  }

  List<vec.Vector2> _basic(double initialR, double finalR) => _drawSide(
        initialR: initialR,
        finalR: finalR,
        frequency: 3,
        intensity: 15,
        minWidth: 5,
        maxWidth: 40,
        cleanProb: 1,
      );
  List<vec.Vector2> _cuted(double initialR, double finalR) => _drawSide(
        initialR: initialR,
        finalR: finalR,
        frequency: 5,
        intensity: 10,
        minWidth: 7,
        maxWidth: 15,
      );

  List<vec.Vector2> _drawSide({
    double initialR = 0,
    required double finalR,
    int frequency = 1,
    double intensity = 1,
    double minWidth = 0,
    double maxWidth = 100000,
    int cleanProb = 5,
  }) {
    Random rnd = Random();

    final List<vec.Vector2> vectors = [];

    final double biggerLimit = max(initialR, finalR);
    double last = min(initialR, finalR);
    int ceroInY = 0;

    int repetitions = 0;

    do {
      repetitions++;
      if (repetitions > 500) {
        throw Exception(
            "(Bucle Infinito) => Do While => _drawSide() => PaperConfig");
      }

      vec.Vector2 point = vec.Vector2(0, 0);

      // Y side
      if (ceroInY >= 2) {
        point.y = rnd.nextDouble() * intensity;
        ceroInY = 0;
      } else if (ceroInY > 0) {
        point.y = 0;
        ceroInY++;
      } else {
        point.y =
            rnd.nextInt(cleanProb) == 0 ? 0 : rnd.nextDouble() * intensity;
        if (point.y == 0) ceroInY++;
      }

      // X side
      // final double diff = (biggerLimit - last).abs();
      final double diff = biggerLimit;
      double withFreq = diff / frequency;

      // En caso de que se quiera un espacio limpio minimo y que
      // estemos tratando con un espacio limpio
      // var cleanMind = cleanSize != null && (point.y == 0 && ceroInY == 2)
      //     ? max(diff, cleanSize)
      //     : diff;

      var intenseMind = (point.y > intensity * .7)
          ? _lerp(point.y, maxWidth, intensity)
          : withFreq;

      var x = max(minWidth, min(maxWidth, intenseMind));

      if (diff < minWidth * 3) x = diff;

      point.x = rnd.nextInt(x.round()) + last;

      last = point.x;

      point.x = point.x.round().toDouble();
      point.y = point.y.round().toDouble();
      vectors.add(point);
    } while (last < biggerLimit - 10);

    return initialR > finalR ? vectors.reversed.toList() : vectors;
  }

  List<vec.Vector2> _drawCuted(Iterable<vec.Vector2> original) {
    Random rnd = Random();

    final List<vec.Vector2> offset = [];

    for (final point in original) {
      double inX = rnd.nextDouble();
      double inY = rnd.nextDouble();

      inX = max(inX, 0.98);
      inY = max(inY, 0.9);

      final newOffset = vec.Vector2(point.x * inX, point.y * inY);

      offset.add(newOffset);
    }

    return offset;
  }

  void _createPaperPath(Size size) {
    final path = Path();

    // Draw Paper
    for (final point in getVectorPath) {
      path.lineTo(point.x, point.y);
    }

    path.close();

    _paperPath = path;
  }

  void _createInterShadow(Size size) {
    final path = Path();
    // Draw Paper
    for (final point in getVectorPath) {
      final perturvation = opositeDirection(size, point);

      path.lineTo(perturvation.x, perturvation.y);
    }

    path.close();

    _randomShadow = path;
  }

  double _lerp(double y, double maxX, double maxY) {
    double z = maxY / (maxX * y);

    return z;
  }

  vec.Vector2 opositeDirection(Size size, vec.Vector2 toEdit) {
    final rnd = Random();

    final middle = vec.Vector2(size.width / 2, size.height / 2);

    double rndX = rnd.nextDouble() * 10;
    double rndY = rnd.nextDouble() * 10;

    var res = vec.Vector2(0, 0);

    if (toEdit.x < middle.x) {
      res.x = toEdit.x - rndX;
    } else {
      res.x = toEdit.x + rndX;
    }

    if (toEdit.y < middle.y) {
      res.y = toEdit.y - rndY;
    } else {
      res.y = toEdit.y + rndY;
    }

    return res;
  }
}
