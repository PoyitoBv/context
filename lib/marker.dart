import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

class Marker extends StatefulWidget {
  Marker(String key, this.coordinate,
      {required this.initialPosition,
      required this.initialScale,
      required this.addMarkerState,
      required this.size,
      required this.child})
      : super(key: Key(key));

  final Point initialPosition;
  final double initialScale;
  final LatLng coordinate;
  final void Function(MarkerState) addMarkerState;

  final Size size;
  final Widget child;

  //! Esto "Ignore" no está bien, revisa este código
  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    final state = MarkerState(
      initialPosition,
      initialScale,
      size: size,
      child: child,
    );
    addMarkerState(state);
    return state;
  }
}

class MarkerState extends State with TickerProviderStateMixin {
  MarkerState(
    this._position,
    this._scale, {
    required this.size,
    required this.child,
  });

  Point _position;
  double _scale;
  final Size size;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    var ratio = 1.0;

    return Positioned(
      left: _position.x / ratio - (size.width * _scale) / 2,
      top: _position.y / ratio - (size.height * _scale) / 2,
      child: SizedBox(
        height: size.height * _scale,
        width: size.width * _scale,
        child: child,
      ),
    );
  }

  void updatePosition(Point<num> point, double scale) {
    setState(() {
      _position = point;
      _scale = scale;
    });
  }

  LatLng getCoordinate() => (widget as Marker).coordinate;

  Point<num> getPoint() => _position;

  bool sameCoords(LatLng toCompare) =>
      (widget as Marker).coordinate == toCompare;
}
