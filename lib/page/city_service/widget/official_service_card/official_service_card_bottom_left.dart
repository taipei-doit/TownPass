import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_text.dart';

class OfficialServiceCardBottomLeft extends OfficialServiceCard {
  const OfficialServiceCardBottomLeft({super.key});

  @override
  Color get borderColor => TPColors.grayscale100;

  @override
  Widget layoutBuild(BuildContext context, BoxConstraints constraint) {
    return SizedBox(
      height: constraint.maxWidth / goldenRatio,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Health(),
          TPLine.horizontal(margin: EdgeInsets.symmetric(horizontal: 12)),
          _GovernmentApp(),
        ],
      ),
    );
  }
}

class _Health extends StatelessWidget {
  const _Health();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // TODO: add link
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    '防疫醫療',
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.primary500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TPText(
                    'Health',
                    style: TPTextStyles.caption,
                    color: TPColors.grayscale700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox.fromSize(
              size: const Size.square(48),
              child: Assets.svg.iconCovidMedical.svg(),
            ),
          ],
        ),
      ),
    );
  }
}

class _GovernmentApp extends StatelessWidget {
  const _GovernmentApp();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        // TODO: add link
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    '市政APP',
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.primary500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TPText(
                    'More',
                    style: TPTextStyles.caption,
                    color: TPColors.grayscale700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox.fromSize(
              size: const Size.square(48),
              child: Assets.svg.iconMore.svg(),
            ),
          ],
        ),
      ),
    );
  }
}
