import 'package:flutter/material.dart';

class TEST extends StatefulWidget {
  const TEST({super.key});

  @override
  State<TEST> createState() => _TESTState();
}

class _TESTState extends State<TEST> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: IconButton(
        onPressed: () => super.dispose(),
        icon: Icon(Icons.delete),
      ),
    );
  }
}

class TextWrap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: TextWrapPainter(),
      child: Container(),
    );
  }
}

class TextWrapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Definir el área del objeto (círculo en este caso)
    Rect circleRect = Rect.fromCircle(center: Offset(200, 100), radius: 50);
    Paint circlePaint = Paint()..color = Colors.blue;

    // Dibujar el objeto
    canvas.drawCircle(circleRect.center, circleRect.width / 2, circlePaint);

    // Definir el estilo del texto
    TextStyle textStyle = TextStyle(
      color: Colors.black,
      fontSize: 18,
    );

    // El texto a dibujar
    String text =
        'Este es un ejemplo de texto que se ajusta al lado de un objeto gráfico como un círculo. '
        'Puedes seguir escribiendo y verás cómo se ajusta alrededor del objeto.';

    // Dividir el texto en palabras
    List<String> words = text.split(' ');

    double x = 20;
    double y = 20;
    double lineHeight = 24;
    double maxWidth = size.width - 20;
    double maxHeight = size.height - 20;

    // Variables para controlar el límite de la línea
    double maxLineWidth = maxWidth;

    // Ajustar el texto alrededor del objeto
    for (String word in words) {
      // Calcular el ancho del texto
      TextSpan span = TextSpan(text: word + ' ', style: textStyle);
      TextPainter tp =
          TextPainter(text: span, textDirection: TextDirection.ltr);
      tp.layout();

      if (x + tp.width > maxLineWidth) {
        // Saltar a la siguiente línea si el texto se sale del ancho permitido
        x = 20;
        y += lineHeight;

        // Resetear el límite de la línea
        maxLineWidth = maxWidth;
      }

      // Ajustar el límite de la línea si hay colisión con el objeto
      if (y < circleRect.bottom && y + lineHeight > circleRect.top) {
        if (x < circleRect.right) {
          maxLineWidth = circleRect.left - 20;
        }
      }

      // Dibujar la palabra si cabe en la línea
      if (y + lineHeight <= maxHeight) {
        tp.paint(canvas, Offset(x, y));
      }

      // Mover la posición x
      x += tp.width;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
