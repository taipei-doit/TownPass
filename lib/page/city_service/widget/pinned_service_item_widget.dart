import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/model/my_service_model.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class PinnedServiceItemWidget extends StatelessWidget {
  final MyServiceItem service;
  final GestureTapCallback? onTap;
  final bool? isEdit;

  const PinnedServiceItemWidget({
    super.key,
    required this.service,
    this.onTap,
    this.isEdit,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap?.call ??
          switch (service.destinationUrl.isNotEmpty) {
            true => () async => await TPRoute.openUri(
                  uri: service.destinationUrl,
                  forceTitle: service.forceWebViewTitle,
                ),
            false => null,
          },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Column(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: TPColors.white,
                child: service.icon,
              ),
              const SizedBox(height: 4),
              TPText(
                service.title,
                style: TPTextStyles.bodySemiBold,
                color: TPColors.grayscale700,
              ),
            ],
          ),
          if (isEdit ?? false) ...[
            Positioned(
              top: 2,
              right: 11,
              child: Container(
                decoration: const ShapeDecoration(
                  shape: CircleBorder(),
                  shadows: [
                    BoxShadow(
                      color: TPColors.grayscale100,
                      blurRadius: 8,
                      offset: Offset(0, 1),
                      spreadRadius: 0,
                    )
                  ],
                ),
                child: Assets.svg.iconRemove.svg(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
