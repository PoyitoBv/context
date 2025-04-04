import 'package:context/paper_draw.dart';
import 'package:flutter/material.dart';

import 'package:animated_text_kit/animated_text_kit.dart';

import 'package:context/custom_card.dart';
import 'package:context/image_mask.dart';
import 'package:context/pausable_typed_text.dart';

class TypedAnimation extends StatefulWidget {
  const TypedAnimation({super.key});

  @override
  State<TypedAnimation> createState() => _TypedAnimationState();
}

class _TypedAnimationState extends State<TypedAnimation>
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late PaperConfig _paperConfig;

  @override
  void initState() {
    _scrollController = ScrollController();
    _paperConfig = PaperConfig(false, false, false, false);
    _paperConfig.initialize(const Size(500, 200));

    groups.add(getOneGroup(0));

    super.initState();
  }

  final List<Widget> groups = [];
  final List<double> contentSizes = [];

  double height = 200;

  void _onPause(bool x) {}

  void _showOneMore() async {
    if (groups.length >= _historia.length) return;

    await Future.delayed(const Duration(seconds: 2));

    groups.add(getOneGroup(groups.length));
    contentSizes.add(24);
    setState(() {});
  }

  void _changeSize(int i, double value) {
    contentSizes.length <= i
        ? contentSizes.add(value)
        : contentSizes[i] = value;

    final double newHeight = contentSizes.reduce((a, b) => a + b) +
        64 +
        80 +
        (contentSizes.length * 32) -
        24;

    if (height >= newHeight) return;

    setState(() => height = newHeight);

    if (_scrollController.position.pixels <
        _scrollController.position.maxScrollExtent - 250) return;

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        controller: _scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: Colors.orange,
              margin: const EdgeInsets.all(24),
              // duration: const Duration(milliseconds: 300),
              // curve: Curves.easeInOut,
              height: height,
              width: 500,
              constraints: const BoxConstraints(minHeight: 100),
              child: CustomCard(
                cutBottom: true,
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    children: groups,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget getOneGroup(int i) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Stack(
        children: [
          Container(
              width: double.infinity,
              margin: const EdgeInsets.only(right: 200),
              child: _getTextAnimation(i)),
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

  Widget _getTextAnimation(int i) {
    return DefaultTextStyle(
      style: const TextStyle(
        fontSize: 14,
        fontFamily: 'Cinzel',
      ),
      child: AnimatedTextKit(
        pause: const Duration(seconds: 3),
        isRepeatingAnimation: false,
        animatedTexts: [
          PausableTypedText(
            _historia[i],
            i,
            onPause: _onPause,
            toUpdate: _changeSize,
          ),
        ],
        onFinished: _showOneMore,
        onTap: () {},
        onNext: (x, y) {},
        onNextBeforePause: (x, y) {},
      ),
    );
  }
}

final List<String> _historia = [
  "In my relationship with Laura, everything started wonderfully. At first, I loved how we shared interests and how she made me feel special. However, over time, I began to notice signs of control and manipulation that I initially overlooked.",
  "Laura started making disparaging comments about my friends and family, gradually isolating me from them. Instead of going out and enjoying activities, we spent more time at home, and she always found excuses to criticize or belittle me. Sometimes, these criticisms would escalate into intense arguments that, at their peak, included shouting and, on occasion, pushing.",
  "I remember one time when the situation reached a critical point. After an argument, Laura shoved me against the wall and told me I was worthless without her. I felt trapped and helpless, but still tried to hold on to hope that things would change.",
  "Eventually, a friend noticed the marks on my arms and the signs of my emotional distress. He offered support and helped me understand that what I was experiencing was abuse. It was a difficult process, but with his help, I sought professional assistance and began taking steps to leave the relationship.",
  "Looking back now, I realize the importance of recognizing warning signs and seeking support when facing an abusive situation. Overcoming an abusive relationship is not easy, but it is possible with the right support and the determination to prioritize one's well-being.",
];
