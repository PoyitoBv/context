import 'dart:developer';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:rive/rive.dart';

import 'package:context/map_controller.dart';
import 'package:context/rive_assets.dart';

class VictimAnimation extends StatefulWidget {
  const VictimAnimation(
    this.id, {
    required this.setToDestroy,
    required this.setToLeave,
    super.key,
  });

  final String id;
  final Function setToDestroy;
  final void Function(void Function() x) setToLeave;

  @override
  State<VictimAnimation> createState() => _VictimAnimationState();
}

class _VictimAnimationState extends State<VictimAnimation> {
  late RiveFile _file;
  late VicAnimController _animController;

  @override
  void initState() {
    _file = RiveAssets().victimAnimation;
    _animController = VicAnimController();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        _animController.onHoverEnter();
      },
      onExit: (_) {
        _animController.onHoverLeave();
      },
      child: GestureDetector(
        onTap: _animController.onClick,
        child: RiveAnimation.direct(
          _file,
          onInit: (art) => _animController.onInit(
            art,
            widget.id,
            setToDestroy: widget.setToDestroy,
            setToLeave: widget.setToLeave,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class VicAnimController {
  final math.Random _rnd = math.Random();

  // StateMachine Controller
  // late StateMachineController _controller;

  late String id;

  SMITrigger? _onLeave;
  SMITrigger? _onClick;
  SMITrigger? _onHoverEnter;
  SMITrigger? _onHoverLeave;
  SMIInput<bool>? _rightLeft; // True = Right | false = Left
  SMIInput<double>? _movement;
  // SMIInput<double>? _gender;
  SMIInput<bool>? _toDestroy;

  int lastMove = 0;
  bool moviendo = false;

  void onInit(
    Artboard art,
    String id, {
    required Function setToDestroy,
    required void Function(void Function() x) setToLeave,
  }) {
    this.id = id;

    var ctrl = StateMachineController.fromArtboard(art, 'main')
        as StateMachineController;
    ctrl.addEventListener(onRiveEvent);
    // ctrl.isActive = true;

    art.addController(ctrl);

    // _controller = ctrl;

    _onLeave = ctrl.findInput<bool>('onLeave') as SMITrigger?;
    _onClick = ctrl.findInput<bool>('onClick') as SMITrigger?;
    _onHoverEnter = ctrl.findInput<bool>('isHover') as SMITrigger?;
    _onHoverLeave = ctrl.findInput<bool>('isNotHover') as SMITrigger?;

    _rightLeft = ctrl.findInput<bool>('RightLeft') as SMIBool?;
    _movement = ctrl.findInput<double>('Movement') as SMINumber?;
    // _gender = ctrl.findInput<double>('Gender') as SMINumber?;

    _toDestroy = ctrl.findInput<bool>('toDestroy') as SMIBool?;

    // _move();

    // Setear el controlador para cuando se destruya
    setToDestroy(_destroy);
    setToLeave(onLeave);
  }

  void onRiveEvent(RiveEvent event) {
    // log(event.toString());

    // if (event.name == "FinishMove") {
    //   _movement!.value = 0;

    //   _move();
    // }
  }

  void onClick() {
    _onClick?.fire();
    MapController().onSelectMarker(id);
  }

  void onLeave() => _onLeave?.fire();

  void onHoverEnter() => _onHoverEnter?.fire();
  void onHoverLeave() => _onHoverLeave?.fire();

  void _move() async {
    if (_movement == null || _rightLeft == null) return;
    if (moviendo) return;

    moviendo = true;

    await Future.delayed(const Duration(seconds: 5));

    int newMove;

    do {
      newMove = _rnd.nextInt(8) + 1;
    } while (newMove == lastMove);

    int? flipNewValue = [1, 4, 7].contains(newMove)
        ? 1
        : [2, 5, 8].contains(newMove)
            ? 2
            : 3;

    int? flipOldValue = [1, 4, 7].contains(lastMove)
        ? 1
        : [2, 5, 8].contains(lastMove)
            ? 2
            : 3;

    _movement!.value = newMove.toDouble();

    if (flipNewValue != flipOldValue) {
      _rightLeft!.value = flipNewValue > flipOldValue;
    }

    lastMove = newMove;

    moviendo = false;
  }

  void inZone(String zone) => log(zone);

  Future<void> _destroy() async {
    if (_toDestroy == null) return;

    _toDestroy!.value = true;

    await Future.delayed(const Duration(seconds: 1));
  }
}
