import 'dart:math';

import 'package:flutter/material.dart';

import 'package:mapbox_gl/mapbox_gl.dart';

import 'package:context/animations_controller.dart';
import 'package:context/marker.dart';
import 'package:context/problem_animation.dart';
import 'package:context/victim_animation.dart';

class MapController with ChangeNotifier {
  static final MapController _instance = MapController._internal();

  factory MapController() => _instance;

  MapController._internal();

  // ignore: constant_identifier_names
  static const String ACCESS_TOKEN =
      'pk.eyJ1IjoicG95aXRvIiwiYSI6ImNseG1jczNqeDAyZWoybHB0cTN5dHFrbWQifQ.g8EzOJluCY5o5x3o5gl8YQ';

  // -------------------------

  final Random _rnd = Random();

  late BuildContext context;
  late MapboxMapController _mapController;

  late AnimationController _animCameraCtrl;
  late Animation<double> _cameraCurve;
  late AnimationController _animMarkerCtrl;
  late Animation<double> _markerCurve;

  bool get smallScreen => MediaQuery.of(context).size.width < 700;
  Size get screenSize => MediaQuery.of(context).size;

  final List<MarkerControll> _markers = [];

  List<Marker> get markers => _markers.map((e) => e.marker).toList();
  List<MarkerState> get _markerStates {
    final List<MarkerState> list = [];

    for (final mark in _markers) {
      if (mark.markerState != null) list.add(mark.markerState!);
    }

    return list;
  }

  MarkerControll? _titleSelected;
  MarkerControll? _selected;

  Victim get victimSelected {
    try {
      Victim victim = _selected!.subject as Victim;
      return victim;
    } catch (_) {
      throw AssertionError(" [El Subjet no fue identificado correctamente] ");
    }
  }

  Problem get titleSelected {
    try {
      Problem problem = _selected!.subject as Problem;
      return problem;
    } catch (_) {
      throw AssertionError(" [El Subjet no fue identificado correctamente] ");
    }
  }

  late LatLng _initialCamPos;
  late LatLng _finalCamPos;
  late Point<num> _initialMarkPos;
  late Point<num> _finalMarkPos;

  bool get isSelected => _selected != null;
  bool get isTitleSelected => _titleSelected != null;
  bool get isSomethingSelected => isSelected || isTitleSelected;
  bool selectingMoving = false;
  bool reviewingMovement = false;
  bool hidingTitle = false;
  bool unselecting = false;

  // ----------------------------------

  //* ===== Initial Functions =====

  void onMapCreated(MapboxMapController ctrl) {
    _mapController = ctrl;

    // Add Listeners
    _mapController.addListener(() {
      if (_mapController.isCameraMoving) {
        _movementReviewer();
      }
    });
    _mapController.addListener(() {
      if (_mapController.isCameraMoving) {
        _updateMarkerPosition();
      }
    });

    // _mapController.animateCamera(CameraUpdate.newCameraPosition(
    //     const CameraPosition(target: LatLng(20.879961, -100.929315))));
  }

  void styleLoaded() {
    // _addMarker();
  }

  void setUpAnimCtrls(TickerProvider vsync) {
    // Camera Animation
    _animCameraCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(milliseconds: 1500),
    );
    _animCameraCtrl.addListener(_animateCamera);

    _cameraCurve = CurvedAnimation(
      parent: _animCameraCtrl,
      curve: Curves.easeOutCubic,
    );

    // Marker Animation
    _animMarkerCtrl = AnimationController(
      vsync: vsync,
      duration: const Duration(seconds: 1),
    );
    _animMarkerCtrl.addListener(_animateMarker);

    _markerCurve = CurvedAnimation(
      parent: _animMarkerCtrl,
      curve: Curves.easeInOutQuart,
    );
  }

  //* ===== Movement Functions

  void _movementReviewer() async {
    if (selectingMoving) return;
    if (reviewingMovement) return;
    reviewingMovement = true;

    // --- Remove Selected on Move
    if (isSelected) _unSelect(_selected!);

    // --- Remove All on ZoomOut
    if (_mapController.cameraPosition!.zoom < 5.5) {
      if (_markers.isNotEmpty) {
        await _destroyAll();

        notifyListeners();
      }

      reviewingMovement = false;

      return;
    }

    // --- Review Content Position
    final LatLngBounds visibleRegion = await _mapController.getVisibleRegion();
    final List<MarkerControll> newList = [];

    // Revisar actuales
    for (final mark in _markers) {
      final bool isVisible =
          await _isCoordinateVisible(visibleRegion, mark.cords);

      if (isVisible) {
        newList.add(mark);
        continue;
      }

      if (hidingTitle) continue;
      if (isThisTitleSelected(mark.id)) {
        _unSelect(_titleSelected!);
        await _unSelectTitle();

        _titleSelected = null;
      }
    }

    // Minimizar TitleSelected
    if (isTitleSelected && !hidingTitle) {
      AnimationsController().minimizeShowed();
    }

    // Añadir Victimas Visibles
    newList.addAll((await _nowVisibleVictims(visibleRegion))
        .where((e) => !newList.map((f) => f.id).contains(e.id)));

    // Añadir Problemas Visibles
    newList.addAll((await _nowVisibleProblems(visibleRegion))
        .where((e) => !newList.map((f) => f.id).contains(e.id)));
    // ----------

    final bool dontChange = _haveSameItems(
        _markers.map((e) => e.id).toList(), newList.map((e) => e.id).toList());

    if (!dontChange) {
      _markers.clear();
      _markers.addAll(newList);

      notifyListeners();
    }

    // ----------

    reviewingMovement = false;
  }

  void onCameraIdleCallback() {
    // _updateMarkerPosition();
  }

  Future<List<MarkerControll>> _nowVisibleVictims(
      LatLngBounds visibleRegion) async {
    final List<MarkerControll> newList = [];

    final List<Victim> victims = FFAppState.victims;

    for (final victim in victims) {
      final bool isVisible =
          await _isCoordinateVisible(visibleRegion, victim.cords);
      if (isVisible) {
        final newMarkerControll =
            MarkerControll(victim.id, ProblemType.victim, subject: victim);

        final newBeMarker = BeMarker(
          cords: victim.cords,
          id: victim.id,
          size: const Size(300.0, 300.0),
          animation: VictimAnimation(
            victim.id,
            setToDestroy: newMarkerControll.setToDestroy,
            setToLeave: newMarkerControll.setToLeave,
          ),
        );

        newList.add(_newMarker(newBeMarker, newMarkerControll));
      }
    }

    return newList;
  }

  Future<List<MarkerControll>> _nowVisibleProblems(
      LatLngBounds visibleRegion) async {
    final List<MarkerControll> newList = [];

    final List<Problem> problems = FFAppState.problems;

    for (final problem in problems) {
      final bool isVisible =
          await _isCoordinateVisible(visibleRegion, problem.cords);
      if (isVisible) {
        final newMarkerControll =
            MarkerControll(problem.id, ProblemType.title, subject: problem);

        final newBeMarker = BeMarker(
          cords: problem.cords,
          id: problem.id,
          size: const Size(880.0 / 3, 280.0 / 3),
          animation: ProblemAnimation(
            problem.id,
            title: problem.title,
            subtitle: problem.subtitle,
            setToDestroy: newMarkerControll.setToDestroy,
            setToLeave: newMarkerControll.setToLeave,
            setToHide: newMarkerControll.setToHide,
          ),
        );

        newList.add(_newMarker(newBeMarker, newMarkerControll));
      }
    }

    return newList;
  }

  MarkerControll _newMarker(BeMarker toMark, MarkerControll markerControll) {
    LatLng coordinates = toMark.cords;
    Point<num>? point;

    _mapController.toScreenLocationBatch([coordinates]).then((value) {
      point = value.first;
    });
    point ??= const Point<num>(0, 0);

    final newMarker = Marker(
      _rnd.nextInt(100000).toString(),
      coordinates,
      initialPosition: point!,
      initialScale: .5,
      addMarkerState: markerControll.setMarkerState,
      size: toMark.size,
      child: toMark.animation,
    );

    markerControll.marker = newMarker;
    markerControll.cords = coordinates;

    return markerControll;
  }

  void _updateMarkerPosition() {
    if (_markers.isEmpty) return;

    final coordinates = <LatLng>[];

    for (final markerState in _markerStates) {
      coordinates.add(markerState.getCoordinate());
    }

    // Calculate Scale
    double scale = _calculateScale(_mapController.cameraPosition!.zoom);

    _mapController.toScreenLocationBatch(coordinates).then((points) {
      _markerStates.asMap().forEach((i, value) {
        if (isTitleSelected &&
            !hidingTitle &&
            _markerStates[i]
                .sameCoords(_titleSelected!.markerState!.getCoordinate())) {
          _markerStates[i].updatePosition(Point(screenSize.width / 2, 80), 1.2);
        } else {
          _markerStates[i].updatePosition(points[i], scale);
        }
      });
    });
  }

  Future<void> _destroyAll() async {
    List<Future> destroyAnimations = [];

    for (final marker in _markers) {
      destroyAnimations.add(marker.destroy());
    }

    await Future.wait(destroyAnimations);

    _markers.clear();
    _selected = null;
    _titleSelected = null;
  }

  //* ===== Interaction Functions
  void onSelectMarker(String id) async {
    final markIndex = _markers.indexWhere((e) => e.id == id);

    if (markIndex == -1) return;

    final marker = _markers[markIndex];
    if (isAlreadySelected(marker)) return;

    switch (marker.type) {
      case ProblemType.title:
        _titleSelected = marker;
        if (isSelected) _unSelect(_selected!);
        break;
      default:
        _selected = marker;
        if (isTitleSelected && !hidingTitle) _titleSelected!.hide(true);
        break;
    }

    final LatLngBounds visibleRegion = await _mapController.getVisibleRegion();

    double yFinal = marker.cords.latitude;
    double xFinal = marker.cords.longitude;

    if (marker.type != ProblemType.title) {
      if (!smallScreen) {
        final double minX = visibleRegion.northeast.longitude;
        final double maxX = visibleRegion.southwest.longitude;
        final double xTercio = (maxX - minX) / 5;

        xFinal = marker.cords.longitude - (xTercio);
      } else {
        final double minY = visibleRegion.northeast.latitude;
        final double maxY = visibleRegion.southwest.latitude;
        final double yTercio = (maxY - minY) / 3;

        yFinal = marker.cords.latitude + (yTercio / 2);
      }
    }

    selectingMoving = true;
    _initialCamPos = _mapController.cameraPosition!.target;
    _finalCamPos = LatLng(yFinal, xFinal);

    final List<Future> toAnimate = [];

    if (_animCameraCtrl.isCompleted) _animCameraCtrl.reset();
    toAnimate.add(_animCameraCtrl.forward());

    if (marker.type == ProblemType.title) {
      _initialMarkPos = marker.markerState!.getPoint();
      _finalMarkPos = Point(screenSize.width / 2, 80);

      if (_animMarkerCtrl.isCompleted) _animMarkerCtrl.reset();
      toAnimate.add(_animMarkerCtrl.forward());
    }

    //* Ejecutar acciones en FlutterFlow
    marker.type == ProblemType.title
        ? AnimationsController().showTitleSelected()
        : AnimationsController().showSelected();

    await Future.wait(toAnimate);

    selectingMoving = false;
  }

  void onClick(Point<double> point) async {
    //? Por ahora solo lo necesito para esto
    if (!isTitleSelected) return;
    if (selectingMoving) return;
    if (unselecting) return;
    if (hidingTitle) return;
    if (point.y < 150) return;

    _unSelect(_titleSelected!);
    await _unSelectTitle();

    _titleSelected = null;
  }

  Future<void> _unSelect(MarkerControll selected) async {
    selected.leave();

    if (isSelected) {
      if (unselecting) return;
      unselecting = true;

      await AnimationsController().hideSelected();
      if (isTitleSelected) _titleSelected!.hide(false);

      _selected = null;
      unselecting = false;
      return;
    }
  }

  Future<void> _unSelectTitle() async {
    hidingTitle = true;

    final LatLng cords = _titleSelected!.markerState!.getCoordinate();

    _initialMarkPos = _titleSelected!.markerState!.getPoint();

    _mapController.toScreenLocationBatch([cords]).then((points) {
      _finalMarkPos = points.first;
    });

    final List<Future> toWait = [];

    if (_animMarkerCtrl.isCompleted) _animMarkerCtrl.reset();
    toWait.add(_animMarkerCtrl.forward());
    toWait.add(AnimationsController().hideAll());

    await Future.wait(toWait);
    await Future.delayed(const Duration(milliseconds: 500));

    hidingTitle = false;
  }

  // ============= Funcioens Auxiliares =============

  void _animateCamera() {
    final lat = _lerp(
        _initialCamPos.latitude, _finalCamPos.latitude, _cameraCurve.value);
    final lng = _lerp(
        _initialCamPos.longitude, _finalCamPos.longitude, _cameraCurve.value);

    _mapController.moveCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: _mapController.cameraPosition!.zoom,
    )));
  }

  void _animateMarker() async {
    Point<num> finalPos = const Point(0, 0);

    if (hidingTitle) {
      finalPos = (await _mapController.toScreenLocationBatch(
              [_titleSelected!.markerState!.getCoordinate()]))
          .first;
    } else {
      finalPos = _finalMarkPos;
    }

    final y = _lerp(_initialMarkPos.y.toDouble(), finalPos.y.toDouble(),
        _markerCurve.value);
    final x = _lerp(_initialMarkPos.x.toDouble(), finalPos.x.toDouble(),
        _markerCurve.value);

    double initialScale = _calculateScale(_mapController.cameraPosition!.zoom);
    final z = hidingTitle
        ? _lerp(1.2, initialScale, _markerCurve.value)
        : _lerp(initialScale, 1.2, _markerCurve.value);

    _titleSelected!.markerState!.updatePosition(Point(x, y), z);
  }

  double _calculateScale(double zoom) {
    double x0 = 3;
    double y0 = .5;

    double x1 = 6;
    double y1 = 1;

    // Fórmula de interpolación lineal
    double y = y0 + ((y1 - y0) / (x1 - x0)) * (zoom - x0);

    return y;
  }

  Future<bool> _isCoordinateVisible(
      LatLngBounds visibleRegion, LatLng coordinate) async {
    LatLng southwest = visibleRegion.southwest;
    LatLng northeast = visibleRegion.northeast;

    // Verifica si la latitud está dentro del rango
    bool isLatitudeVisible = coordinate.latitude >= southwest.latitude &&
        coordinate.latitude <= northeast.latitude;

    // Verifica si la longitud está dentro del rango
    bool isLongitudeVisible = coordinate.longitude >= southwest.longitude &&
        coordinate.longitude <= northeast.longitude;

    // Devuelve true si ambas condiciones son verdaderas
    return isLatitudeVisible && isLongitudeVisible;
  }

  bool _haveSameItems(List<String> list1, List<String> list2) {
    return Set.from(list1).difference(Set.from(list2)).isEmpty &&
        Set.from(list2).difference(Set.from(list1)).isEmpty;
  }

  double _lerp(double start, double end, var value) {
    return start + (value * (end - start));
  }

  bool isThisTitleSelected(String id) {
    return isTitleSelected && _titleSelected!.id == id;
  }

  bool isAlreadySelected(MarkerControll mark) {
    return (isSelected && _selected!.id == mark.id) ||
        (isTitleSelected && _titleSelected!.id == mark.id);
  }
}

class MarkerControll {
  MarkerControll(this.id, this.type, {required this.subject});
  // Objeto
  // final XXXX problem;
  final String id;
  final ProblemType type;

  late Marker marker;
  late LatLng cords;
  final dynamic subject;

  MarkerState? markerState;

  Future<void> Function()? _toDestroy;
  void Function()? _toLeave;
  void Function(bool)? _toHide;

  void setMarkerState(MarkerState state) => markerState = state;
  void setToDestroy(Future<void> Function() destroy) => _toDestroy = destroy;
  void setToLeave(void Function() leave) => _toLeave = leave;
  void setToHide(void Function(bool) hide) => _toHide = hide;

  Future<void> destroy() async {
    if (_toDestroy == null) return;

    await _toDestroy!();
  }

  void leave() {
    if (_toLeave == null) return;

    _toLeave!();
  }

  void hide(bool hide) {
    if (_toHide == null) return;

    _toHide!(hide);
  }
}

class BeMarker {
  const BeMarker({
    required this.cords,
    required this.id,
    required this.size,
    required this.animation,
  });

  final LatLng cords;
  final String id;

  final Size size;
  final Widget animation;
}

//! Clase Temporal, esta info viene de FFAppState
class FFAppState {
  static List<Victim> victims = [
    Victim(const LatLng(27.521527, -113.324872), name: "Miguel"),
    Victim(const LatLng(65.980629, -153.220569), name: "Andres"),
    Victim(const LatLng(77.329670, -42.891462), name: "Sofia"),
    Victim(const LatLng(63.512395, 99.704256), name: "Monica"),
    Victim(const LatLng(-14.141685, 24.258157), name: "Estefi"),
    Victim(const LatLng(-25.803603, 134.174345), name: "Canguro"),
    Victim(const LatLng(36.035894, 138.261506), name: "Onichan"),
    Victim(const LatLng(39.776707, -4.473723), name: "Tio"),
    Victim(const LatLng(-27.037942, -62.461216), name: "Ché"),
  ];

  static List<Problem> problems = [
    Problem(const LatLng(-23.889675, 125.962795), title: "Canguros Boxeadores"),
    Problem(const LatLng(37.416976, 139.464040), title: "Muchos Virgenes"),
    Problem(const LatLng(70.908064, 98.514366), title: "Rico Frio"),
    Problem(const LatLng(50.785585, 35.247644), title: "Guerra en Ucrania"),
    Problem(const LatLng(39.821551, -3.905632), title: "Madre mia Willy"),
    Problem(const LatLng(-22.220020, 45.739894),
        title: "Quieren mover el Bote"),
    Problem(const LatLng(-24.407168, -65.625275), title: "Canivales :c"),
    Problem(const LatLng(20.439442, -88.450503), title: "Bajo el Mar"),
    Problem(const LatLng(21.656113, -78.441084),
        title: "Oye Chico", subtitle: "Ejque yo soy cubano, chico"),
    Problem(const LatLng(27.211732, -81.238911),
        title: "Oh Yeah, Diamantes", subtitle: "De lunes a domingo voooy"),
  ];
}

//! Clase Temporal, Crear con FF
class Victim {
  Victim(
    this.cords, {
    required this.name,
    this.history = "Tengo una historia",
    this.character = 1,
  }) {
    id = "${cords.latitude}$name${cords.longitude}";
  }

  late String id;

  final LatLng cords;
  final int character;

  final String name;
  final String history;
}

//! Clase Temporal, Crear con FF
class Problem {
  Problem(
    this.cords, {
    required this.title,
    this.subtitle,
  }) {
    id = "${cords.latitude}$title${cords.longitude}";
  }

  late String id;

  final LatLng cords;

  final String title;
  final String? subtitle;
}

enum ProblemType { victim, title }
