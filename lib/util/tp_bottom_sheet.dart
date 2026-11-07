import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_colors.dart';

/// 通用的底部抽屜容器元件
class TPBottomSheet extends StatelessWidget {
  final Widget child;
  final bool useSafeArea;

  const TPBottomSheet({
    super.key,
    required this.child,
    this.useSafeArea = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: TPColors.white,
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 6,
          ),
        ],
      ),
      child: SafeArea(
        left: useSafeArea,
        top: useSafeArea,
        right: useSafeArea,
        bottom: useSafeArea,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [child],
        ),
      ),
    );
  }
}
