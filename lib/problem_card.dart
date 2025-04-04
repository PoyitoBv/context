import 'package:flutter/material.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:context/animations_controller.dart';
import 'package:context/custom_card.dart';
import 'package:context/map_controller.dart';

class ProblemCard extends StatefulWidget {
  const ProblemCard({super.key});

  @override
  State<ProblemCard> createState() => _ProblemCardState();
}

class _ProblemCardState extends State<ProblemCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _initialAnimCtrl;
  late Animation<double> _positionCurve;
  late Animation<double> _sizeCurve;

  bool isVisible = false;
  bool animating = false;

  @override
  void initState() {
    AnimationsController().showTitleSelected = _show;
    AnimationsController().hideTitleSelected = _hide;

    _initialAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // _animCameraCtrl.addListener(_animateCamera);
    _positionCurve = Tween<double>(
      begin: 1,
      end: -0.1,
    ).animate(CurvedAnimation(
      parent: _initialAnimCtrl,
      curve: Curves.easeInOutQuart,
      reverseCurve: Curves.easeInOutCubic,
    ));
    _sizeCurve = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _initialAnimCtrl,
      curve: Curves.easeInOutQuart,
      reverseCurve: Curves.easeInOutCubic,
    ));

    super.initState();
  }

  Future<void> _show() async {
    if (isVisible || animating) return;
    animating = true;

    setState(() => isVisible = true);
    _initialAnimCtrl.forward();

    animating = false;
  }

  Future<void> _hide() async {
    if (!isVisible || animating) return;
    animating = true;

    await _initialAnimCtrl.reverse();
    setState(() => isVisible = false);

    animating = false;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return !isVisible
        ? const SizedBox.shrink()
        : !MapController().isTitleSelected
            ? const Text("Ocurrió un error inesperado.")
            : AnimatedBuilder(
                animation: _initialAnimCtrl,
                builder: (context, child) {
                  return Positioned(
                    bottom: 0 - (_positionCurve.value * size.height),
                    left: 0,
                    right: 0,
                    child: Transform.scale(
                      scaleX: _sizeCurve.value,
                      alignment: Alignment.bottomCenter,
                      child: child!,
                    ),
                  );
                },
                child: Center(
                  child: Container(
                    width: size.width * .9,
                    height: size.height * 0.7,
                    constraints: const BoxConstraints(
                      maxWidth: 800,
                      minWidth: 300,
                    ),
                    child: PointerInterceptor(
                      child: CustomCard(child: const _ProblemContent()),
                    ),
                  ),
                ),
              );
  }
}

class _ProblemContent extends StatelessWidget {
  const _ProblemContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Hola Mundo"));
  }
}
