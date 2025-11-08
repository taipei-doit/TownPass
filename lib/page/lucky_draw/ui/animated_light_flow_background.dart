import 'dart:math';

import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

class AnimatedLightFlowBackground extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;

  const AnimatedLightFlowBackground({
    super.key,
    required this.child,
    required this.backgroundColor,
  });

  @override
  State<AnimatedLightFlowBackground> createState() =>
      _AnimatedLightFlowBackgroundState();
}

class _AnimatedLightFlowBackgroundState
    extends State<AnimatedLightFlowBackground> with TickerProviderStateMixin {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  final int _particleCount = 8;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(
      _particleCount,
      (index) => AnimationController(
        duration: Duration(
          milliseconds: 8000 + _random.nextInt(4000),
        ),
        vsync: this,
      )..repeat(),
    );

    _animations = _controllers
        .map((controller) => Tween<double>(begin: 0, end: 1).animate(
              CurvedAnimation(
                parent: controller,
                curve: Curves.linear,
              ),
            ))
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          color: widget.backgroundColor,
        ),
        ...List.generate(
          _particleCount,
          (index) => AnimatedBuilder(
            animation: _animations[index],
            builder: (context, child) {
              return Positioned.fill(
                child: CustomPaint(
                  painter: LightFlowPainter(
                    progress: _animations[index].value,
                    seed: index,
                  ),
                ),
              );
            },
          ),
        ),
        widget.child,
      ],
    );
  }
}

class LightFlowPainter extends CustomPainter {
  final double progress;
  final int seed;
  final Random _random;

  LightFlowPainter({
    required this.progress,
    required this.seed,
  }) : _random = Random(seed);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30);

    // 為每個粒子生成固定的隨機參數
    final startX = _random.nextDouble() * size.width;
    final startY = size.height + 50;
    const endY = -50.0;
    final amplitude = 30 + _random.nextDouble() * 40;
    final frequency = 3 + _random.nextDouble() * 2.5;
    final phase = _random.nextDouble() * 2 * pi;

    // 計算當前位置（往上移動）
    final currentY = startY + (endY - startY) * progress;
    final currentX =
        startX + amplitude * sin(frequency * progress * 2 * pi + phase);

    // 創建漸變效果 - 增加不透明度
    final gradient = RadialGradient(
      colors: [
        TPColors.secondary200.withAlpha(100),
        TPColors.secondary200.withAlpha(50),
        TPColors.secondary200.withAlpha(0),
      ],
      stops: const [0.0, 0.5, 1.0],
    );

    final rect = Rect.fromCircle(
      center: Offset(currentX, currentY),
      radius: 100,
    );

    paint.shader = gradient.createShader(rect);
    canvas.drawCircle(Offset(currentX, currentY), 100, paint);

    // 添加小光點 - 增加不透明度
    final smallPaint = Paint()
      ..style = PaintingStyle.fill
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    final smallGradient = RadialGradient(
      colors: [
        TPColors.secondary200.withAlpha(128),
        TPColors.secondary200.withAlpha(0),
      ],
      stops: const [0.0, 1.0],
    );

    final smallRect = Rect.fromCircle(
      center: Offset(currentX, currentY),
      radius: 40,
    );

    smallPaint.shader = smallGradient.createShader(smallRect);
    canvas.drawCircle(Offset(currentX, currentY), 40, smallPaint);
  }

  @override
  bool shouldRepaint(LightFlowPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
