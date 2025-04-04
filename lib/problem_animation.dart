import 'package:flutter/material.dart';

import 'package:rive/rive.dart';

import 'package:context/map_controller.dart';
import 'package:context/rive_assets.dart';

class ProblemAnimation extends StatefulWidget {
  const ProblemAnimation(
    this.id, {
    required this.title,
    this.subtitle,
    required this.setToDestroy,
    required this.setToLeave,
    required this.setToHide,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String id;

  final Function setToDestroy;
  final Function setToLeave;
  final Function setToHide;

  @override
  State<ProblemAnimation> createState() => _ProblemAnimationState();
}

class _ProblemAnimationState extends State<ProblemAnimation> {
  late RiveFile _file;
  late ProbAnimController _animController;

  @override
  void initState() {
    _file = RiveAssets().titleAnimation;
    _animController = ProbAnimController(widget.title,
        subtitle: widget.subtitle, id: widget.id);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {},
      onExit: (_) {},
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _animController.onClick,
        child: RiveAnimation.direct(
          _file,
          onInit: (art) => _animController.onInit(
            art,
            setToDestroy: widget.setToDestroy,
            setToLeave: widget.setToLeave,
            setToHide: widget.setToHide,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ProbAnimController {
  ProbAnimController(this.title, {this.subtitle, required this.id});

  final String title;
  final String? subtitle;

  final String id;

  // StateMachine Controller
  // late StateMachineController _controller;

  SMITrigger? _onShowZone;
  SMITrigger? _onHideZone;

  SMIInput<bool>? _toDestroy;

  int lastMove = 0;
  bool moviendo = false;

  void onInit(
    Artboard art, {
    required Function setToDestroy,
    required Function setToLeave,
    required Function setToHide,
  }) {
    var ctrl = StateMachineController.fromArtboard(art, 'main')
        as StateMachineController;
    // ctrl.isActive = true;

    art.addController(ctrl);
    // _controller = ctrl;

    _onShowZone = ctrl.findInput<bool>('ShowZone') as SMITrigger;
    _onHideZone = ctrl.findInput<bool>('HideZone') as SMITrigger;

    _toDestroy = ctrl.findInput<bool>('toDestroy') as SMIBool;

    // ==== Set Text's
    final titleRun = art.textRun('Title')!;
    titleRun.text = title;

    final subtitleRun = art.textRun('Subtitle')!;
    subtitleRun.text = subtitle ?? "";

    // Setear el controlador para cuando se destruya
    setToDestroy(_destroy);
    setToLeave(onLeave);
    setToHide(hide);
  }

  void wannaShow() => _onShowZone?.fire();
  void wannaHide() => _onHideZone?.fire();

  void onClick() {
    MapController().onSelectMarker(id);
  }

  void onLeave() {}
  void hide(bool? hide) {
    if (hide == null) return;

    hide ? wannaHide() : wannaShow();
  }

  // Animación que ocurre cuando se aleja el zoom
  Future<void> _destroy() async {
    if (_toDestroy == null) return;

    _toDestroy!.value = true;
    // wannaHide();

    await Future.delayed(const Duration(seconds: 1));
  }
}

extension _TextExtension on Artboard {
  TextValueRun? textRun(String name) => component<TextValueRun>(name);
}
