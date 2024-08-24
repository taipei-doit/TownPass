import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/bean/mosaic_tile_service.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/city_service_view_controller.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

/// 服務頁面中段，四個卡牌的 UI 元件。
///
/// 4-Card service widget, which can be located at the mid of [ServiceView].
class MosaicTileWidget extends StatelessWidget {
  const MosaicTileWidget({super.key});

  MosaicTileService get service => Get.find<CityServiceViewController>().staticService.value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(goldenRatio),
          1: FixedColumnWidth(8.0),
          2: FlexColumnWidth(1.0),
        },
        children: [
          TableRow(
            children: [
              _topLeftCard,
              const SizedBox.shrink(),
              _topRightCard,
            ],
          ),
          TableRow(
            children: List.filled(
              3,
              const SizedBox(height: 8.0),
            ),
          ),
          TableRow(
            children: [
              _bottomLeftCard,
              const SizedBox.shrink(),
              _bottomRightCard,
            ],
          ),
        ],
      ),
    );
  }

  /// 左上卡片。
  ///
  /// Top-left corner card.
  Widget get _topLeftCard {
    return LayoutBuilder(
      builder: (context, constraint) {
        return _Card(
          padding: EdgeInsets.zero,
          height: constraint.maxWidth / goldenRatio,
          gradient: _backgroundGradient,
          onTap: () {
            if (service.contentList[0].url.isNotEmpty) {
              Get.toNamed(
                TPRoute.webView,
                arguments: service.contentList[0].url,
              );
            }
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Align(
                alignment: Alignment.bottomLeft,
                child: SizedBox.square(
                  dimension: constraint.maxWidth * 0.67,
                  child: Align(
                    alignment: Alignment.bottomLeft,
                    child: _icon(keyName: service.contentList[0].icon),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 17.0),
                      TPText(
                        service.contentList[0].mainText,
                        style: TPTextStyles.h3SemiBold,
                        color: TPColors.white,
                      ),
                      const SizedBox(height: 2.0),
                      TPText(
                        service.contentList[0].subText,
                        style: TPTextStyles.bodyRegular,
                        color: TPColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 右上卡片。
  ///
  /// Top-right corner card.
  Widget get _topRightCard {
    return LayoutBuilder(
      builder: (_, constraint) {
        return _Card(
          height: constraint.maxWidth,
          backgroundColor: TPColors.white,
          borderColor: TPColors.grayscale100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CardSplitButton(
                item: service.contentList[1],
                iconSize: const Size.square(24),
              ),
              const TPLine.horizontal(),
              _CardSplitButton(
                item: service.contentList[2],
                iconSize: const Size.square(24),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 左下卡片。
  ///
  /// Bottom-left corner card.
  Widget get _bottomLeftCard {
    return LayoutBuilder(
      builder: (_, constraint) {
        return _Card(
          height: constraint.maxWidth / goldenRatio,
          backgroundColor: TPColors.white,
          borderColor: TPColors.grayscale100,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _CardSplitButton(
                item: service.contentList[3],
                iconSize: const Size.square(48),
              ),
              const TPLine.horizontal(),
              _CardSplitButton(
                item: service.contentList[4],
                iconSize: const Size.square(48),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 右下卡片。
  ///
  /// Bottom-right corner card.
  Widget get _bottomRightCard {
    return LayoutBuilder(
      builder: (_, constraint) {
        return _Card(
          height: constraint.maxWidth,
          padding: EdgeInsets.zero,
          gradient: _backgroundGradient,
          onTap: () {
            if (service.contentList[5].url.isNotEmpty) {
              Get.toNamed(
                TPRoute.webView,
                arguments: service.contentList[5].url,
              );
            }
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0, bottom: 4),
                child: Align(
                  alignment: Alignment.bottomLeft,
                  child: SizedBox.square(
                    dimension: constraint.maxWidth * 0.45,
                    child: Align(
                      alignment: Alignment.bottomLeft,
                      child: _icon(keyName: service.contentList[5].icon),
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(right: 9.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const SizedBox(height: 17.0),
                      TPText(
                        service.contentList[5].mainText,
                        style: TPTextStyles.h3SemiBold,
                        color: TPColors.white,
                      ),
                      const SizedBox(height: 2.0),
                      TPText(
                        service.contentList[5].subText,
                        style: TPTextStyles.bodyRegular,
                        color: TPColors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 卡片漸層背景。
  ///
  /// Gradient background for cards.
  static Gradient get _backgroundGradient {
    return const LinearGradient(
      begin: Alignment(0.71, 0.71),
      end: Alignment(-0.71, -0.71),
      colors: [
        Color(0xB344B6C7),
        Color(0xFF44B6C7),
      ],
    );
  }
}

/// 圓角卡牌。
///
/// Rounded-corner card.
class _Card extends StatelessWidget {
  /// 單一背景顏色；[backgroundColor] 與 [gradient] 至少有一者得為 null。
  ///
  /// Static background color; One of [backgroundColor] and [gradient] must be
  /// null.
  final Color? backgroundColor;

  /// 漸層背景顏色；[backgroundColor] 與 [gradient] 至少有一者得為 null。
  ///
  /// Gradient background color; One of [backgroundColor] and [gradient] must be
  /// null.
  final Gradient? gradient;

  /// 卡片邊緣顏色。
  ///
  /// Border color.
  final Color? borderColor;

  /// 卡片 Padding，預設為 [EdgeInsets.all(12.0)]。
  ///
  /// Card's padding, default is [EdgeInsets.all(12.0)].
  final EdgeInsets? padding;

  /// 卡片中的 UI 元件。
  ///
  /// The widget below [_Card] in the tree.
  final Widget child;

  /// 卡片高度。
  ///
  /// Card's height.
  final double height;

  /// 點擊後行為。
  ///
  /// Behavior after been tapped.
  final GestureTapCallback? onTap;

  const _Card({
    this.backgroundColor,
    this.gradient,
    this.borderColor,
    this.padding,
    required this.height,
    required this.child,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Container(
        padding: padding ?? const EdgeInsets.all(12.0),
        height: height,
        decoration: ShapeDecoration(
          color: backgroundColor,
          gradient: gradient,
          shape: RoundedRectangleBorder(
            side: BorderSide(color: borderColor ?? Colors.transparent),
            borderRadius: BorderRadius.circular(6.0),
          ),
        ),
        child: child,
      ),
    );
  }
}

/// 對分卡片的按鈕。見右上與左下卡片內容。
///
/// The button that split the card. See more in top-right and bottom-left
/// cards.
class _CardSplitButton extends StatelessWidget {
  final MosaicTileServiceItem item;

  final Size iconSize;

  const _CardSplitButton({
    required this.item,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (item.url.isNotEmpty) {
          Get.toNamed(
            TPRoute.webView,
            arguments: item.url,
          );
        }
      },
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TPText(
                  item.mainText,
                  style: TPTextStyles.h3SemiBold,
                  color: TPColors.primary500,
                  overflow: TextOverflow.ellipsis,
                ),
                TPText(
                  item.subText,
                  style: TPTextStyles.caption,
                  color: TPColors.grayscale700,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          SizedBox.fromSize(
              size: iconSize,
              child: _icon(
                keyName: item.icon,
              )),
        ],
      ),
    );
  }
}

Widget _icon({required String keyName}) {
  return Assets.svg.values
          .firstWhereOrNull(
            (svg) => keyName == svg.keyName,
          )
          ?.svg() ??
      const SizedBox.shrink();
}
