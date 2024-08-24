import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/gen/fonts.gen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class SubscriptionWidget extends StatelessWidget {
  const SubscriptionWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '訂閱',
            style: TextStyle(
              color: Color(0xFF30383D),
              fontSize: 20,
              fontFamily: FontFamily.pingFangTC,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
          color: const Color(0xFFEDF8FA),
          child: Row(
            children: [
              Assets.svg.illustrationsBookingS.svg(width: 54, height: 46),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '活動、服務、福利 一鍵讓你知',
                    style: TextStyle(
                      color: Color(0xFF30383D),
                      fontSize: 16,
                      fontFamily: FontFamily.pingFangTC,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      // TODO: do subscription setting page
                    },
                    child: const Text(
                      '訂閱設定',
                      style: TextStyle(
                        color: Color(0xFF5AB4C5),
                        fontSize: 16,
                        fontFamily: FontFamily.pingFangTC,
                        fontWeight: FontWeight.w400,
                        decoration: TextDecoration.underline,
                        decorationColor: Color(0xFF5AB4C5),
                      ),
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
