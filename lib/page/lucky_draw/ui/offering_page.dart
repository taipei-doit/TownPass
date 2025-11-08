import 'package:flutter/material.dart';
import 'package:town_pass/page/lucky_draw/ui/animated_light_flow_background.dart';
import 'package:town_pass/page/lucky_draw/ui/lucky_draw_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';

class OfferingPage extends StatefulWidget {
  const OfferingPage({super.key});

  @override
  State<OfferingPage> createState() => _OfferingPageState();
}

class _OfferingPageState extends State<OfferingPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: LuckyDrawAppBar(subtitle: '獻供'),
      body: AnimatedLightFlowBackground(
        backgroundColor: TPColors.secondary50,
        child: Placeholder(),
      ),
    );
  }
}
