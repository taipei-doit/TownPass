import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/util/tp_colors.dart';

class AccountAppBar extends StatelessWidget implements PreferredSizeWidget {
  const AccountAppBar({super.key});

  @override
  Size get preferredSize => const Size.fromHeight(161);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment(0.00, -1.00),
          end: Alignment(0, 1),
          colors: [Color(0xFF5AB4C5), Color(0xFF4B8DBF)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 44),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: CircleAvatar(
                      radius: 40.0,
                      backgroundColor: TPColors.grayscale200,
                      child: Assets.svg.user.svg(),
                    ),
                  ),
                ),
                Align(
                  alignment: Alignment.topRight,
                  child: CloseButton(
                    color: TPColors.white,
                    style: const ButtonStyle(
                      padding: WidgetStatePropertyAll(EdgeInsets.all(16.0)),
                    ),
                    onPressed: () => Get.back(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
