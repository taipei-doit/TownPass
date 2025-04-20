import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_card.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:url_launcher/url_launcher.dart';

class OnlinePoliceView extends StatelessWidget {
  const OnlinePoliceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '警政報案系統'),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const TPText('網路報案', style: TPTextStyles.h3SemiBold),
            const SizedBox(height: 4),
            _Card(
                icon: Assets.svg.iconOnlineReporting.svg(),
                onTap: () async => await TPRoute.openUri(
                      uri: 'https://taipei-pass-service.vercel.app/police-report',
                    ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          TPText('網路報案', style: TPTextStyles.h3SemiBold),
                          TPText('性質如同110，為報案管道之一種，填寫相關資料，進行報案'),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    Assets.svg.iconExpand.svg(),
                  ],
                )),
            const SizedBox(height: 8),
            _Card(
              icon: Assets.svg.iconCaseSearch.svg(),
              onTap: () async => await TPRoute.openUri(
                uri: 'https://taipei-pass-service.vercel.app/police-report/record',
              ),
              child: Row(
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TPText('案件查詢', style: TPTextStyles.h3SemiBold),
                      TPText('案件進度查詢'),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 8.0),
                  Assets.svg.iconExpand.svg(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const TPText('語音報案', style: TPTextStyles.h3SemiBold),
            const SizedBox(height: 4),
            Column(
              children: [
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Card(
                          icon: Assets.svg.icon110.svg(),
                          onTap: () async => await launchUrl(Uri.parse('tel://110')),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TPText('110', style: TPTextStyles.h3SemiBold),
                              TPText('緊急報案'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Card(
                          icon: Assets.svg.icon119.svg(),
                          onTap: () async => await launchUrl(Uri.parse('tel://119')),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TPText('119', style: TPTextStyles.h3SemiBold),
                              TPText('火災通報'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                IntrinsicHeight(
                  child: Row(
                    children: [
                      Expanded(
                        child: _Card(
                          icon: Assets.svg.icon165.svg(),
                          onTap: () async => await launchUrl(Uri.parse('tel://165')),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TPText('165', style: TPTextStyles.h3SemiBold),
                              TPText('反詐騙專線'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _Card(
                          icon: Assets.svg.icon113.svg(),
                          onTap: () async => await launchUrl(Uri.parse('tel://113')),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TPText('113', style: TPTextStyles.h3SemiBold),
                              TPText('婦幼保護申訴專線'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Card extends TPCard {
  final GestureTapCallback? onTap;
  final Widget icon;

  const _Card({
    this.onTap,
    required this.icon,
    required super.child,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: TPCard(
        cornerRadius: 8,
        child: Stack(
          children: [
            const Positioned(
              top: -15.0,
              left: -7.0,
              child: CircleAvatar(
                radius: 32.0,
                backgroundColor: TPColors.primary100,
              ),
            ),
            Positioned(
              top: 3.0,
              left: 9.0,
              child: icon,
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(76.0, 12.0, 12.0, 12.0),
              child: child,
            ),
          ],
        ),
      ),
    );
  }
}
