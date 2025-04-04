// import 'dart:ui' as ui;

// import 'package:flutter/material.dart';

// class ShaderController {
//   static final ShaderController _instance = ShaderController._internal();

//   factory ShaderController() => _instance;

//   ShaderController._internal();

//   late final ui.FragmentProgram _vignette;
//   ui.FragmentProgram get vignette => _vignette;

//   late final ui.FragmentProgram _grain;
//   ui.FragmentProgram get grain => _grain;

//   void initShaderController(ui.FragmentProgram vig, ui.FragmentProgram grain) {
//     _vignette = vig;
//     _grain = grain;
//   }
// }

// class VignettePainter {
//   Paint paint(Size size) {
//     final ui.FragmentShader vignette =
//         ShaderController().vignette.fragmentShader();

//     const Color color = ui.Color.fromARGB(134, 74, 48, 1);

//     vignette.setFloat(0, size.width); // u_resolution.x
//     vignette.setFloat(1, size.height); // u_resolution.y
//     vignette.setFloat(2, -0.2); // u_roundness
//     vignette.setFloat(3, color.red / 255); // uColor.R
//     vignette.setFloat(4, color.green / 255); // uColor.G
//     vignette.setFloat(5, color.blue / 255); // uColor.B
//     vignette.setFloat(6, 1); // uColor.A
//     vignette.setFloat(7, 0.42); // u_smoothness
//     vignette.setFloat(8, 0.26); // u_width
//     vignette.setFloat(9, 0.26); // u_height

//     final vignettePaint = Paint()..shader = vignette;

//     return vignettePaint;
//   }
// }

// class TexturePainter {
//   Paint paint(Size size, Color color) {
//     final ui.FragmentShader shaderCut =
//         ShaderController().grain.fragmentShader();

//     shaderCut.setFloat(0, size.width); // u_resolution.x
//     shaderCut.setFloat(1, size.height); // u_resolution.y
//     shaderCut.setFloat(2, 1.5); // u_grain_amount
//     shaderCut.setFloat(3, 0.1); // u_fx
//     shaderCut.setFloat(4, color.red / 255); // uColor.R
//     shaderCut.setFloat(5, color.green / 255); // uColor.G
//     shaderCut.setFloat(6, color.blue / 255); // uColor.B
//     shaderCut.setFloat(7, 1); // uColor.B

//     final texture = Paint()
//       ..shader = shaderCut
//       ..blendMode = BlendMode.overlay;

//     return texture;
//   }
// }
