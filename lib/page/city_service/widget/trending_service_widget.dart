import 'package:flutter/material.dart';
import 'package:town_pass/page/city_service/model/trending_service_model.dart';
import 'package:town_pass/util/extension/list.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

/// 服務頁面底部，熱門服務 UI 元件，
///
/// Trending service widget, which can be located at the bottom of
/// [ServiceView].
class TrendingServiceWidget extends StatelessWidget {
  const TrendingServiceWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      explicitChildNodes: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TPText(
              '熱門',
              style: TPTextStyles.h3SemiBold.copyWith(fontSize: 18.0),
              color: TPColors.grayscale900,
            ),
          ),
          const SizedBox(height: 7.0),
          Table(children: _tableRowList),
        ],
      ),
    );
  }

  /// 所有熱門的按鈕列表；順序在畫面中由左至右，由上至下。
  ///
  /// list of all trending-service's buttons; The order on screen is
  /// left-to-right, top-to-bottom.
  static List<_ServiceButton> get _list => TrendingServiceModel.serviceList
      .map<_ServiceButton>(
        (item) => _ServiceButton(
          icon: item.icon,
          title: item.title,
          onTap: () async => await TPRoute.openUri(
            uri: item.url,
            forceTitle: item.forceWebViewTitle,
          ),
        ),
      )
      .toList();

  /// [Table] 直行內各按鈕間距(Space Around)。
  ///
  /// Space between each [Table] buttons (Space Around).
  static Widget get _columnSpacer {
    return const SizedBox(width: 32.0);
  }

  /// [Table] 的橫列間距。
  ///
  /// Spacer between each [Table]'s row.
  static TableRow get _rowSpacer {
    return const TableRow(
      children: [SizedBox(height: 16.0)],
    );
  }

  // 倘若每橫列按鈕數量更改(當前為 2)，底下邏輯也須作調整。
  //
  // If you decide to change the amount of buttons in a row (it's 2 now),
  // modify the logics below.

  /// 由 [_list] 產生 [Table] 的所有橫列。
  ///
  /// Generate [Table.children] from [_list].
  static List<TableRow> get _tableRowList {
    return List<TableRow>.generate(
      _list.length ~/ 2 + _list.length % 2,
      (index) => TableRow(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Expanded(child: _list[index * 2]),
              Expanded(
                child: switch (index * 2 + 1 < _list.length) {
                  true => _list[index * 2 + 1],
                  false => const SizedBox.shrink(),
                },
              ),
            ].joinedAround(_columnSpacer),
          ),
        ],
      ),
    ).joined(_rowSpacer);
  }
}

/// 熱門服務按鈕元件。
///
/// Trending-service button.
class _ServiceButton extends StatelessWidget {
  /// 服務圖示。
  ///
  /// Icon for the service.
  final Widget icon;

  /// 服務標題。
  ///
  /// Title for the service.
  final String title;

  /// 點擊後行為。
  ///
  /// Behavior after been tapped.
  final GestureTapCallback? onTap;

  /// 熱門服務按鈕。
  ///
  /// Trending-service button.
  const _ServiceButton({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Row(
        children: [
          SizedBox.square(
            dimension: 48,
            child: icon,
          ),
          const SizedBox(width: 8.0),
          Flexible(
            child: TPText(
              title,
              style: TPTextStyles.h3Regular,
              color: Colors.black,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
