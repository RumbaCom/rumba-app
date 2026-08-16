import 'package:flutter/material.dart';

import '../theme.dart';

/// El logo dentro de un disco que gira solo mientras suena la radio.
class SpinningLogo extends StatefulWidget {
  final bool spinning;
  final double size;

  const SpinningLogo({
    super.key,
    required this.spinning,
    this.size = 240,
  });

  @override
  State<SpinningLogo> createState() => _SpinningLogoState();
}

class _SpinningLogoState extends State<SpinningLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  );

  @override
  void initState() {
    super.initState();
    if (widget.spinning) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant SpinningLogo old) {
    super.didUpdateWidget(old);

    if (widget.spinning && !_c.isAnimating) {
      _c.repeat();
    } else if (!widget.spinning && _c.isAnimating) {
      // Se frena suave en vez de cortarse de golpe.
      _c.stop();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: RumbaColors.surfaceHigh,
          border: Border.all(
            color: widget.spinning ? RumbaColors.accent : RumbaColors.track,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: Padding(
            padding: EdgeInsets.all(widget.size * 0.04),
            child: RotationTransition(
              turns: _c,
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
