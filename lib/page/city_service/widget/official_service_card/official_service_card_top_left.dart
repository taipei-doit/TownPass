import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_text.dart';

class OfficialServiceCardTopLeft extends OfficialServiceCard {
  const OfficialServiceCardTopLeft({super.key});

  @override
  Widget layoutBuild(BuildContext context, BoxConstraints constraint) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // TODO: add url
      },
      child: Container(
        height: constraint.maxWidth / goldenRatio,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6.0),
          gradient: const LinearGradient(
            begin: Alignment(0.71, 0.71),
            end: Alignment(-0.71, -0.71),
            colors: [
              Color(0xB344B6C7),
              Color(0xFF44B6C7),
            ],
          ),
        ),
        child: Stack(
          fit: StackFit.passthrough,
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: SizedBox.square(
                dimension: constraint.maxWidth * 0.67,
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: Assets.svg.illustrationsGov.svg(),
                ),
              ),
            ),
            const Positioned.fill(
              right: 9.0,
              top: 17.0,
              child: Column(
                spacing: 2.0,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  TPText(
                    '市政服務',
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.white,
                  ),
                  TPText(
                    'Service',
                    style: TPTextStyles.bodyRegular,
                    color: TPColors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
