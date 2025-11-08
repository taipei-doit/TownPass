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
    const val = 15.0;
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
      body: Placeholder(),
    );
  }
}
