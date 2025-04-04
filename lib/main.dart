import 'package:flutter/material.dart';

import 'package:context/map.dart';
import 'package:context/rive_assets.dart';

// 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

void main() async {
  // final ui.FragmentProgram vignette =
  //     await ui.FragmentProgram.fromAsset("assets/shaders/vignette.frag");
  // final ui.FragmentProgram grain =
  //     await ui.FragmentProgram.fromAsset("assets/shaders/grain.frag");
  // ShaderController().initShaderController(vignette, grain);

  runApp(const MyApp());

  RiveAssets().preloadAssets();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Material App',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Home(),
      ),
    );
  }
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return const Stack(
      children: <Widget>[
        CustomMap(),
      ],
    );
  }
}
