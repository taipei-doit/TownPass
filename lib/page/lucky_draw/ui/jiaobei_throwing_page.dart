import 'package:flutter/material.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class JiaobeiThrowingPage extends StatefulWidget {
  const JiaobeiThrowingPage({super.key});

  @override
  State<JiaobeiThrowingPage> createState() => _JiaobeiThrowingPageState();
}

class _JiaobeiThrowingPageState extends State<JiaobeiThrowingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(
        title: '城心誠靈  |  搖一搖擲筊',
        backgroundColor: TPColors.secondary50,
      ),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Container(),
      ),
    );
  }
}
