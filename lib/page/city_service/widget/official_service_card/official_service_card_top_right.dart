import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class OfficialServiceCardTopRight extends OfficialServiceCard {
  const OfficialServiceCardTopRight({super.key});

  @override
  Color get borderColor => TPColors.grayscale100;

  @override
  Widget layoutBuild(BuildContext context, BoxConstraints constraint) {
    return SizedBox(
      height: constraint.maxWidth,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _Presentation(),
          TPLine.horizontal(margin: EdgeInsets.symmetric(horizontal: 12)),
          _GovernmentApp(),
        ],
      ),
    );
  }
}

class _Presentation extends StatelessWidget {
  const _Presentation();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async => await TPRoute.openUri(
        uri: 'https://taipei-pass-service.vercel.app/citizen-report/',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    '有話要說',
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.primary500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TPText(
                    '1999',
                    style: TPTextStyles.caption,
                    color: TPColors.grayscale700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox.fromSize(
              size: const Size.square(24),
              child: Assets.svg.iconTalk.svg(),
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
      onTap: () async => await TPRoute.openUri(
        uri: 'local://online_police',
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    '警政報案',
                    style: TPTextStyles.h3SemiBold,
                    color: TPColors.primary500,
                    overflow: TextOverflow.ellipsis,
                  ),
                  TPText(
                    'Police',
                    style: TPTextStyles.caption,
                    color: TPColors.grayscale700,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            SizedBox.fromSize(
              size: const Size.square(24),
              child: Assets.svg.iconPolice.svg(),
            ),
          ],
        ),
      ),
    );
  }
}
