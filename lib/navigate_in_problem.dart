import 'package:flutter/material.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:context/animations_controller.dart';
import 'package:context/custom_card.dart';
import 'package:context/map_controller.dart';

class NavigateInProblem extends StatefulWidget {
  const NavigateInProblem({super.key});

  @override
  State<NavigateInProblem> createState() => _NavigateInProblemState();
}

class _NavigateInProblemState extends State<NavigateInProblem>
    with SingleTickerProviderStateMixin {
  late AnimationController _initialAnimCtrl;
  late Animation<double> _initialCurve;

  bool isVisible = false;
  bool animating = false;

  @override
  void initState() {
    AnimationsController().showNavigation = _show;
    AnimationsController().hideNavigation = _hide;

    _initialAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // _animCameraCtrl.addListener(_animateCamera);
    _initialCurve = Tween<double>(
      begin: -308,
      end: 24,
    ).animate(CurvedAnimation(
      parent: _initialAnimCtrl,
      curve: Curves.easeInOutQuart,
      reverseCurve: Curves.easeInOutQuart,
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
        : !MapController().isSomethingSelected
            ? const Text("Ocurrió un error inesperado.")
            : AnimatedBuilder(
                animation: _initialAnimCtrl,
                builder: (context, child) {
                  return Positioned(
                    top: 144,
                    right: _initialCurve.value,
                    child: child!,
                  );
                },
                child: PointerInterceptor(
                  child: Container(
                    width: 300,
                    constraints: BoxConstraints(
                      maxHeight: size.height - (144 + 32),
                    ),
                    child: CustomCard(child: const _Nivigation()),
                  ),
                ),
              );
  }
}

class _Nivigation extends StatelessWidget {
  const _Nivigation();

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Hola Mundo"));
  }
}
