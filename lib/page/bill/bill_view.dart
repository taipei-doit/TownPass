import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/bill/widget/bill_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class BillView extends StatelessWidget {
  const BillView({super.key});

  // 新增一個私有資料模型來表示熱門繳費項目
  class _PopularBillItem {
    final Widget icon;
    final String name;
    final String uri;

    const _PopularBillItem({
      required this.icon,
      required this.name,
      required this.uri,
    });
  }

  // 將熱門繳費的資料定義為一個靜態常數列表
  static const List<_PopularBillItem> _popularBillItems = [
    _PopularBillItem(
      icon: Assets.svg.iconBillCar.svg(),
      name: '停車費',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-5/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillWater.svg(),
      name: '水費',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-6/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillLocalTax.svg(),
      name: '地方稅',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/tax-1/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillTuition.svg(),
      name: '學雜費',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-7/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillPublicHousing.svg(),
      name: '國/社宅租金維管費',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-8/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillHospital.svg(),
      name: '聯合醫院醫療費',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-9/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillHousingMaintenance.svg(),
      name: '平價住宅維護費',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-10/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillClass.svg(),
      name: '公訓處自費課程',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/detail/fee-11/',
    ),
    _PopularBillItem(
      icon: Assets.svg.iconBillOther.svg(),
      name: '其他',
      uri: 'https://taipei-pass-service.vercel.app/fee-payment/others/',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const BillAppBar(),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Semantics(
            explicitChildNodes: true,
            child: Row(
              children: [
                TPText(
                  '我的帳單',
                  style: TPTextStyles.h3SemiBold.copyWith(fontSize: 18),
                  color: TPColors.grayscale900,
                ),
                const Spacer(),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: Row(
                    children: [
                      Assets.svg.iconSettings.svg(
                        width: 20,
                        height: 20,
                        colorFilter: const ColorFilter.mode(
                          TPColors.grayscale950,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const TPText(
                        '設定',
                        style: TPTextStyles.bodyRegular,
                        color: TPColors.grayscale950,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12.0),
              itemBuilder: (_, index) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {},
                  child: SizedBox(
                    width: 120 * goldenRatio,
                    child: DottedBorder(
                      color: TPColors.grayscale200,
                      borderType: BorderType.RRect,
                      radius: const Radius.circular(5.0),
                      strokeWidth: 1.5,
                      dashPattern: const [4, 3],
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Semantics(
                              excludeSemantics: true,
                              child: Assets.svg.iconAdd.svg(),
                            ),
                            const TPText(
                              '新增綁定',
                              style: TPTextStyles.bodyRegular,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          TPText(
            '熱門繳費',
            style: TPTextStyles.h3SemiBold.copyWith(fontSize: 18),
            color: TPColors.grayscale900,
          ),
          const SizedBox(height: 12),
          // 使用 map 函式根據 _popularBillItems 列表來動態生成 _BillType 小部件
          ..._popularBillItems.map(
            (item) => _BillType(
              icon: item.icon,
              name: item.name,
              onTap: () async => await TPRoute.openUri(uri: item.uri),
            ),
          ).toList(),
        ],
      ),
    );
  }
}

class _BillType extends StatelessWidget {
  final Widget icon;
  final String name;
  final GestureTapCallback? onTap;

  const _BillType({
    required this.icon,
    required this.name,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => onTap?.call(),
        child: Row(
          children: [
            icon,
            const SizedBox(width: 8),
            TPText(
              name,
              style: TPTextStyles.h3Regular,
            ),
          ],
        ),
      ),
    );
  }
}