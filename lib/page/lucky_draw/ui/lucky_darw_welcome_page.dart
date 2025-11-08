import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class LuckyDarwWelcomePage extends StatefulWidget {
  const LuckyDarwWelcomePage({super.key});

  @override
  State<LuckyDarwWelcomePage> createState() => _LuckyDarwWelcomePageState();
}

class _LuckyDarwWelcomePageState extends State<LuckyDarwWelcomePage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: TPAppBar(title: 'Lucky Draw'),
      backgroundColor: TPColors.white,
      body: Placeholder(),
    );
  }
}
