import 'package:flutter/material.dart';

import 'package:pointer_interceptor/pointer_interceptor.dart';

import 'package:context/animations_controller.dart';
import 'package:context/custom_card.dart';
import 'package:context/map_controller.dart';

import 'image_mask.dart';

class VictimCard extends StatefulWidget {
  const VictimCard({super.key});

  @override
  State<VictimCard> createState() => _VictimCardState();
}

class _VictimCardState extends State<VictimCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _initialAnimCtrl;
  late Animation<double> _initialCurve;

  bool isVisible = false;
  bool animating = false;

  @override
  void initState() {
    AnimationsController().showSelected = _show;
    AnimationsController().hideSelected = _hide;

    _initialAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    // _animCameraCtrl.addListener(_animateCamera);
    _initialCurve = Tween<double>(
      begin: 1,
      end: 0,
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
        : !MapController().isSelected
            ? const Text("Ocurrió un error inesperado.")
            : AnimatedBuilder(
                animation: _initialAnimCtrl,
                builder: (context, child) {
                  return Positioned(
                    bottom: 0 - (_initialCurve.value * size.height),
                    left: size.width / 2,
                    child: child!,
                  );
                },
                child: PointerInterceptor(
                  child: Container(
                    width: (size.width / 16) * 7,
                    height: size.height,
                    constraints: const BoxConstraints(
                      // maxWidth: 600,
                      minWidth: 300,
                    ),
                    child: const _VictimListContent(),
                  ),
                ),
              );
  }
}

class _VictimListContent extends StatefulWidget {
  const _VictimListContent({super.key});

  @override
  State<_VictimListContent> createState() => _VictimListContentState();
}

class _VictimListContentState extends State<_VictimListContent> {
  final GlobalKey _contentKey = GlobalKey();
  Size? _size;

  @override
  void initState() {
    _checkContentSize();

    super.initState();
  }

  void _checkContentSize() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final RenderBox? renderBox =
          _contentKey.currentContext?.findRenderObject() as RenderBox?;
      if (renderBox != null) {
        _size = renderBox.size;

        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyContent = Padding(
      key: _contentKey,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        children: _historia.map((e) => getOneGroup(e)).toList(),
      ),
    );

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 80),
            SizedBox(
              height: 200,
              width: double.infinity,
              child: CustomCard(
                // size: Size(double.infinity, 200),
                cutBottom: true,
                child: const Stack(
                  children: <Widget>[
                    Text("Guerra en Ucrania"),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: _size == null
                  ? Opacity(
                      opacity: 0,
                      child: historyContent,
                    )
                  : CustomCard(
                      size: _size,
                      cutBottom: true,
                      cutTop: true,
                      child: historyContent,
                    ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

Widget getOneGroup(String text) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 24.0),
    child: Stack(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(right: 200),
          child: Text(text),
        ),
        // const SizedBox(width: 32),

        const Align(
          alignment: Alignment.topRight,
          child: SizedBox(
            width: 200,
            child: ImageMask(),
          ),
        ),
      ],
    ),
  );
}

final List<String> _historia = [
  "In my relationship with Laura, everything started wonderfully. At first, I loved how we shared interests and how she made me feel special. However, over time, I began to notice signs of control and manipulation that I initially overlooked.",
  "Laura started making disparaging comments about my friends and family, gradually isolating me from them. Instead of going out and enjoying activities, we spent more time at home, and she always found excuses to criticize or belittle me. Sometimes, these criticisms would escalate into intense arguments that, at their peak, included shouting and, on occasion, pushing.",
  "I remember one time when the situation reached a critical point. After an argument, Laura shoved me against the wall and told me I was worthless without her. I felt trapped and helpless, but still tried to hold on to hope that things would change.",
  "Eventually, a friend noticed the marks on my arms and the signs of my emotional distress. He offered support and helped me understand that what I was experiencing was abuse. It was a difficult process, but with his help, I sought professional assistance and began taking steps to leave the relationship.",
  "Looking back now, I realize the importance of recognizing warning signs and seeking support when facing an abusive situation. Overcoming an abusive relationship is not easy, but it is possible with the right support and the determination to prioritize one's well-being.",
];
