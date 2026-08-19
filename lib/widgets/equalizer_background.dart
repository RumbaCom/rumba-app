import 'dart:math';

import 'package:flutter/material.dart';

/// Fondo de ecualizador: barras azules verticales, de frente, que se
/// mueven mientras suena la radio y se calman al pausar. El movimiento
/// es una animacion (no lee el audio real, algo inviable con streams),
/// pero da el mismo efecto visual del video de referencia.
class EqualizerBackground extends StatefulWidget {
  final bool active;

  const EqualizerBackground({super.key, required this.active});

  @override
  State<EqualizerBackground> createState() => _EqualizerBackgroundState();
}

class _EqualizerBackgroundState extends State<EqualizerBackground>
    with SingleTickerProviderStateMixin {
  static const int _bars = 34;

  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 1),
  )..repeat();

  final Random _rnd = Random();
  final List<double> _vals = List.filled(_bars, 0.06);
  final List<double> _tgt = List.filled(_bars, 0.06);

  @override
  void initState() {
    super.initState();
    for (var i = 0; i < _bars; i++) {
      _tgt[i] = _rnd.nextDouble();
    }
    _c.addListener(_tick);
  }

  void _tick() {
    final active = widget.active;
    for (var i = 0; i < _bars; i++) {
      // Cada tanto, una barra elige una nueva altura objetivo.
      final changeProb = active ? 0.07 : 0.02;
      if (_rnd.nextDouble() < changeProb) {
        _tgt[i] = active ? 0.12 + _rnd.nextDouble() * 0.88 : 0.05;
      }
      // Suaviza hacia el objetivo.
      _vals[i] += (_tgt[i] - _vals[i]) * 0.14;
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        painter: _EqPainter(_c, _vals),
        size: Size.infinite,
      ),
    );
  }
}

class _EqPainter extends CustomPainter {
  final List<double> vals;

  _EqPainter(Listenable repaint, this.vals) : super(repaint: repaint);

  @override
  void paint(Canvas canvas, Size size) {
    final n = vals.length;
    const gap = 4.0;
    final bw = (size.width - (n - 1) * gap) / n;

    // Linea base: las barras crecen hacia arriba desde aqui, y su reflejo
    // cae hacia abajo. Se coloca en la zona baja de la pantalla.
    final baseY = size.height * 0.80;
    final maxH = size.height * 0.52;

    for (var i = 0; i < n; i++) {
      final v = vals[i].clamp(0.0, 1.0);
      final bh = 12 + v * maxH;
      final x = i * (bw + gap);
      final rect = Rect.fromLTWH(x, baseY - bh, bw, bh);

      // Los colores ya llevan su opacidad (barras presentes pero que no
      // tapan el logo). La punta brilla mas que la base.
      final grad = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF8FD2FF).withOpacity(0.62),
          const Color(0xFF1560E0).withOpacity(0.42),
        ],
      );

      final paint = Paint()
        ..shader = grad.createShader(rect)
        ..style = PaintingStyle.fill;

      final rr = RRect.fromRectAndRadius(rect, const Radius.circular(2));
      canvas.drawRRect(rr, paint);

      // Reflejo hacia abajo, mas tenue.
      final rH = bh * 0.45;
      final rRect = Rect.fromLTWH(x, baseY, bw, rH);
      final rPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF5AA0FF).withOpacity(0.22),
            const Color(0xFF5AA0FF).withOpacity(0.0),
          ],
        ).createShader(rRect);
      canvas.drawRect(rRect, rPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _EqPainter oldDelegate) => true;
}
