import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_constant.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class BillAppBar extends StatelessWidget implements PreferredSizeWidget {
  const BillAppBar({super.key});

  double get _bottomHeight => 64 + textSize('text', style: TPTextStyles.bodySemiBold).height + 12 * 2;

  @override
  Size get preferredSize => Size.fromHeight(kTPToolbarHeight + _bottomHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: TPColors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(-1.0, -1.0),
            end: Alignment(1.0, 1.0),
            colors: [Color(0xFF5AB4C5), Color(0xFF4B8DBF)],
          ),
        ),
      ),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Semantics(
              excludeSemantics: true,
              child: Assets.svg.logoS.svg(
                colorFilter: const ColorFilter.mode(
                  TPColors.white,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          const Flexible(
            child: TPText(
              '帳務',
              style: TPTextStyles.h3SemiBold,
              color: TPColors.white,
            ),
          ),
        ],
      ),
      leading: IconButton(
        icon: Semantics(
          label: '帳戶',
          child: Assets.svg.iconPerson.svg(
            colorFilter: const ColorFilter.mode(
              TPColors.white,
              BlendMode.srcIn,
            ),
          ),
        ),
        onPressed: () => Get.toNamed(TPRoute.account),
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(_bottomHeight),
        child: SizedBox(
          height: _bottomHeight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _BottomItem(
                icon: Assets.svg.iconAppBarScan.svg(),
                title: '掃描',
                onTap: () async => await TPRoute.openUri(
                  uri: 'https://taipei-pass-service.vercel.app/fee-payment/scan/',
                ),
              ),
              _BottomItem(
                icon: Assets.svg.iconAppBarAccountingRecord.svg(),
                title: '紀錄',
                onTap: () async => await TPRoute.openUri(
                  uri: 'https://taipei-pass-service.vercel.app/fee-payment/history/',
                ),
              ),
              _BottomItem(
                icon: Assets.svg.iconAppBarBill.svg(),
                title: '發票',
              ),
              _BottomItem(
                icon: Assets.svg.iconAppBarReceipt.svg(),
                title: '收據',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final Widget icon;
  final String title;
  final GestureTapCallback? onTap;

  const _BottomItem({
    required this.icon,
    required this.title,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon,
          TPText(
            title,
            style: TPTextStyles.bodySemiBold,
            color: TPColors.white,
          ),
        ],
      ),
    );
  }
}
