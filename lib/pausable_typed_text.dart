import 'package:flutter/material.dart';

import 'package:animated_text_kit/animated_text_kit.dart';

class PausableTypedText extends AnimatedText {
  static Duration speed = const Duration(milliseconds: 40);
  static Curve curve = Curves.linear;

  /// Bool value returns the animation status after pause.
  ///
  /// true: isPlaying ---- false: isPause
  final Function(bool) onPause;
  final Function(int, double) toUpdate;

  PausableTypedText(
    String text,
    this.index, {
    required this.onPause,
    required this.toUpdate,
  }) : super(
          text: text,
          duration: speed * text.characters.length,
        );

  // Controller for pause the animation
  late AnimationController _controller;
  final GlobalKey _key = GlobalKey();
  final int index;

  late Animation<double> _typingText;
  double _height = 0.0;

  @override
  Duration get remaining => speed * (textCharacters.length - _typingText.value);

  @override
  void initAnimation(AnimationController controller) {
    _controller = controller;

    _typingText = CurveTween(
      curve: curve,
    ).animate(controller);

    _typingText.addListener(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final RenderBox? renderBox =
            _key.currentContext?.findRenderObject() as RenderBox?;

        if (renderBox == null) return;

        if (_height < renderBox.size.height) {
          _height = renderBox.size.height;

          toUpdate(index, _height);
        }
      });
    });
  }

  /// Widget showing partial text, up to [count] characters
  @override
  Widget animatedBuilder(BuildContext context, Widget? child) {
    /// Output of CurveTween is in the range [0, 1] for majority of the curves.
    /// It is converted to [0, textCharacters.length].
    final count =
        (_typingText.value.clamp(0, 1) * textCharacters.length).round();

    assert(count <= textCharacters.length);

    final typedText = textWidget(textCharacters.take(count).toString());

    return GestureDetector(
      key: _key,
      onTap: () {
        _controller.isAnimating ? _controller.stop() : _controller.forward();

        onPause(_controller.isAnimating);
      },
      child: typedText,
    );
  }
}
