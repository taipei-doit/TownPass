import 'package:flutter/material.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card_bottom_left.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card_bottom_right.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card_top_left.dart';
import 'package:town_pass/page/city_service/widget/official_service_card/official_service_card_top_right.dart';
import 'package:town_pass/util/tp_constant.dart';

/// 服務頁面中段，四個卡牌的 UI 元件。
///
/// 4-Card service widget, which can be located at the mid of [ServiceView].
class OfficialServiceCardWidget extends StatelessWidget {
  const OfficialServiceCardWidget({super.key});

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
          const TableRow(
            children: [
              OfficialServiceCardTopLeft(),
              SizedBox.shrink(),
              OfficialServiceCardTopRight(),
            ],
          ),
          TableRow(
            children: List.filled(3, const SizedBox(height: 8.0)),
          ),
          const TableRow(
            children: [
              OfficialServiceCardBottomLeft(),
              SizedBox.shrink(),
              OfficialServiceCardBottomRight(),
            ],
          ),
        ],
      ),
    );
  }
}
