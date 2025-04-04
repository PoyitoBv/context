import 'package:flutter/material.dart';
import 'package:widget_mask/widget_mask.dart';

class ImageMask extends StatelessWidget {
  const ImageMask({super.key});

  @override
  Widget build(BuildContext context) {
    return WidgetMask(
      blendMode: BlendMode.srcATop,
      childSaveLayer: true,
      mask: Image.network(
        "https://pbs.twimg.com/profile_images/1250608993149554689/2-njZugc_400x400.jpg",
        fit: BoxFit.cover,
        alignment: Alignment.topCenter,
      ),
      child: Image.asset(
        "assets/masks/watercolor1.png",
        fit: BoxFit.contain,
      ),
    );
  }
}
