import 'dart:async';

import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:sensors_plus/sensors_plus.dart';

class LuckyDarwWelcomePage extends StatefulWidget {
  const LuckyDarwWelcomePage({super.key});

  @override
  State<LuckyDarwWelcomePage> createState() => _LuckyDarwWelcomePageState();
}

class _LuckyDarwWelcomePageState extends State<LuckyDarwWelcomePage> {
  final _streamSubscription = <StreamSubscription<dynamic>>[];

  _shakeListen() {
    const val = 10.0;
    _streamSubscription
        .add(userAccelerometerEventStream().listen((userAccelerometerEvent) {
      if (userAccelerometerEvent.x.abs() >= val ||
          userAccelerometerEvent.y.abs() >= val ||
          userAccelerometerEvent.z.abs() >= val) {
        // Detected a shake
        print('Device shaken!');
      }
    }));
  }

  @override
  void initState() {
    _shakeListen();
    super.initState();
  }

  @override
  void dispose() {
    for (final subscription in _streamSubscription) {
      subscription.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TPAppBar(
        title: '城心誠靈',
        backgroundColor: TPColors.secondary50,
      ),
      backgroundColor: TPColors.secondary50,
      body: _LuckyDrawPage(),
    );
  }
}

class _LuckyDrawPage extends StatefulWidget {
  const _LuckyDrawPage({super.key});

  @override
  State<_LuckyDrawPage> createState() => _LuckyDrawPageState();
}

class _LuckyDrawPageState extends State<_LuckyDrawPage> {
  final _streamSubscription = <StreamSubscription<dynamic>>[];

  _shakeListen() {
    const threshold = 10.0;

    _streamSubscription.add(
      userAccelerometerEventStream().listen((event) {
        final shook = event.x.abs() > threshold ||
            event.y.abs() > threshold ||
            event.z.abs() > threshold;

        if (shook) {
          print("Device shaken!");

          // ✅ prevent multiple rapid triggers
          _navigateOnce();
        }
      }),
    );
  }

  bool _navigated = false;

  void _navigateOnce() {
    if (_navigated) return; // avoid repeated navigation
    _navigated = true;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Text("Result Page"), // replace with your widget
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F3EB), // light beige background
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: GestureDetector(
                onTap: () {
                  // TODO: handle tap
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.asset(
                    'assets/image/lots.png', // your image here
                    fit: BoxFit.cover,
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
                color: Color(0xFF4D3A2A),
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              "搖動手機或點擊籤筒來抽籤",
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF4D3A2A),
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
                  onPressed: () {
                    // TODO: handle draw stick
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFB54F43), // red color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    "Draw a Stick",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
