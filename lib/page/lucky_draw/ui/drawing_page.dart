import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:lottie/lottie.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:get/route_manager.dart';

class DrawingPage extends StatefulWidget {
  const DrawingPage({super.key});

  @override
  State<DrawingPage> createState() => _DrawingPageState();
}

class _DrawingPageState extends State<DrawingPage>
    with SingleTickerProviderStateMixin {
  final _streamSubscription = <StreamSubscription<dynamic>>[];
  late final AnimationController _lottieController;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();

    // Lottie controller
    _lottieController = AnimationController(vsync: this);
    _lottieController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _navigateOnce();
      }
    });

    _shakeListen();
  }

  void _shakeListen() {
    const threshold = 10.0;

    _streamSubscription.add(
      userAccelerometerEventStream().listen((event) {
        final shook = event.x.abs() > threshold ||
            event.y.abs() > threshold ||
            event.z.abs() > threshold;

        if (shook) {
          _playAnimationOnce();
        }
      }),
    );
  }

  void _playAnimationOnce() {
    if (!_lottieController.isAnimating && !_hasNavigated) {
      _lottieController.reset();
      _lottieController.forward();
    }
  }

  void _navigateOnce() {
    if (_hasNavigated) return;
    _hasNavigated = true;

    Get.toNamed('/lucky_draw/draw_result');
  }

  @override
  void dispose() {
    _lottieController.dispose();
    for (var sub in _streamSubscription) {
      sub.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(
        title: '城心誠靈 - Draw a Stick',
        backgroundColor: TPColors.secondary50,
      ),
      backgroundColor: TPColors.secondary50,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: _playAnimationOnce,
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

            const SizedBox(height: 32),

            // Title
            const Text(
              "Shake your phone \n or tap the holder to draw",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                color: TPColors.red900,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "搖動手機或點擊籤筒來抽籤",
              style: TextStyle(
                fontSize: 16,
                color: TPColors.red900,
              ),
            ),

            const SizedBox(height: 40),

            // Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: _playAnimationOnce,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: TPColors.red700,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Draw a Stick",
                    style: TextStyle(fontSize: 18, color: TPColors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
