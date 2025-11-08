import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:get/route_manager.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with TickerProviderStateMixin {
  final _streamSubscription = <StreamSubscription<dynamic>>[];
  late final AnimationController _lottieController;
  late final AnimationController _floatingController;
  late final Animation<double> _floatingAnimation;

  get _shakingThreshold => Platform.isIOS ? 10.0 : 5.0;

  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();

    // Floating animation controller
    _floatingController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _floatingAnimation = Tween<double>(
      begin: -30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _floatingController,
      curve: Curves.easeInOut,
    ));

    // Lottie controller
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      setState(() => _isAnimating = status == AnimationStatus.forward);

      if (status == AnimationStatus.completed) {
        _navigateOnce();
      }
    });

    _listenShaking();
  }

  void _listenShaking() {
    final threshold = _shakingThreshold;

    _streamSubscription.add(
      userAccelerometerEventStream().listen((event) {
        final shakingValue = sqrt(event.x * event.x + event.y * event.y);
        final isShook = shakingValue > threshold;

        if (isShook) {
          _playAnimationOnce();
        }
      }),
    );
  }

  void _unsubscribeShaking() {
    for (var sub in _streamSubscription) {
      sub.cancel();
    }
  }

  void _playAnimationOnce() {
    if (!_lottieController.isAnimating) {
      _floatingController.stop();
      _lottieController.reset();
      _lottieController.forward();
    }
  }

  void _navigateOnce() async {
    _unsubscribeShaking();
    // await Get.toNamed('/lucky_draw/draw_result');
    await Get.toNamed('/lucky_draw/jiaobei_throwing');
    _floatingController.repeat(reverse: true);
    _listenShaking();
  }

  @override
  void dispose() {
    _lottieController.dispose();
    _floatingController.dispose();
    _unsubscribeShaking();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const LuckyDrawAppBar(subtitle: '搖一搖求籤'),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _lottieAnimation,
              const SizedBox(height: 56),
              _instructionText,
            ],
          ),
        ),
      ),
    );
  }

  Widget get _lottieAnimation => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: GestureDetector(
          onTap: _playAnimationOnce,
          child: AnimatedBuilder(
            animation: _floatingAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(0, _floatingAnimation.value),
                child: child,
              );
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Lottie.asset(
                'assets/lottie_json/draw_lots.json',
                controller: _lottieController,
                width: 300,
                height: 300,
                fit: BoxFit.fill,
                onLoaded: (composition) {
                  _lottieController.duration = composition.duration;
                },
              ),
            ),
          ),
        ),
      );

  Widget get _instructionText {
    if (_isAnimating) {
      return const Text(
        "抽籤中...",
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: TPColors.secondary800,
        ),
      );
    }

    return const Text.rich(TextSpan(
      style: TextStyle(
        fontSize: 24,
        color: TPColors.secondary700,
      ),
      children: [
        TextSpan(
          text: "搖動手機 ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TPColors.secondary800,
          ),
        ),
        TextSpan(text: "或"),
        TextSpan(
          text: " 點擊籤筒 ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: TPColors.secondary800,
          ),
        ),
        TextSpan(text: "開始抽籤"),
      ],
    ));
  }
}
