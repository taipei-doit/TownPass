import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/model/my_service_model.dart';
import 'package:town_pass/page/city_service/widget/pinned_service_widget.dart';
import 'package:town_pass/page/city_service_edit/city_service_edit_view_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_bottom_sheet.dart';
import 'package:town_pass/util/tp_button.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class CityServiceEditView extends GetView<CityServiceEditViewController> {
  const CityServiceEditView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (value, _) {
        if (value) {
          if (controller.isEditMode.value) {
            controller.cancelEdit();
          }
        }
      },
      child: Scaffold(
        appBar: const TPAppBar(title: '我的服務'),
        bottomNavigationBar: TPBottomSheet(
          child: Obx(() {
            if (controller.isEditMode.value) {
              return Row(
                children: [
                  Expanded(
                    child: TPButton.secondary(
                      enable: controller
                          .pinnedServiceController.pinnedList.isNotEmpty,
                      text: '取消',
                      onPressed: () => controller.cancelEdit(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TPButton.primary(
                      text: '儲存',
                      onPressed: () => controller.isEditMode.value =
                          !controller.isEditMode.value,
                    ),
                  )
                ],
              );
            } else {
              return TPButton.primary(
                text: '編輯',
                onPressed: () {
                  controller.isEditMode.value = !controller.isEditMode.value;
                },
              );
            }
          }),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              child: TPText(
                '置頂服務',
                style: TPTextStyles.h3SemiBold,
                color: TPColors.grayscale700,
              ),
            ),
            Obx(
              () {
                return PinnedServiceWidget(
                  isEditMode: controller.isEditMode.value,
                  onMoreTap: () => controller.isEditMode.value =
                      !controller.isEditMode.value,
                  showAddInNewLine: true,
                );
              },
            ),
            const SizedBox(height: 13),
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const BouncingScrollPhysics(),
                itemCount: controller.categoryMap.keys.length,
                itemBuilder: (_, index) {
                  final MyServiceCategory category =
                      controller.categoryMap.keys.toList()[index];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 13),
                        child: TPText(
                          category.title,
                          style: TPTextStyles.h3SemiBold,
                          color: TPColors.grayscale700,
                        ),
                      ),
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: controller.categoryMap[category]?.length,
                        itemBuilder: (_, index) {
                          final MyServiceItemId itemId =
                              controller.categoryMap[category]![index];
                          return Obx(
                            () {
                              return GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                onTap: () async {
                                  if (controller.isEditMode.value) {
                                    switch (controller
                                        .pinnedServiceController.pinnedList
                                        .contains(itemId)) {
                                      case true:
                                        controller.pinnedServiceController
                                            .remove(itemId);
                                      case false:
                                        if (!controller.pinnedServiceController
                                            .push(itemId)) {
                                          Fluttertoast.showToast(
                                              msg: '置頂服務已達上限(12個)');
                                        }
                                    }
                                  } else {
                                    if (itemId.item.destinationUrl.isNotEmpty) {
                                      await TPRoute.openUri(
                                        uri: itemId.item.destinationUrl,
                                      );
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Row(
                                    children: [
                                      SizedBox.square(
                                        dimension: 24,
                                        child: itemId.item.icon,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 8.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              TPText(
                                                itemId.item.title,
                                                style:
                                                    TPTextStyles.bodySemiBold,
                                                color: TPColors.grayscale900,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              const SizedBox(height: 4),
                                              TPText(
                                                itemId.item.description,
                                                style: TPTextStyles.caption,
                                                color: TPColors.grayscale700,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      if (controller.isEditMode.value) ...[
                                        switch (controller
                                            .pinnedServiceController.pinnedList
                                            .contains(itemId)) {
                                          true => Stack(
                                              children: [
                                                Assets.svg.iconUnchecked.svg(
                                                  colorFilter:
                                                      const ColorFilter.mode(
                                                    TPColors.primary500,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                                const Icon(
                                                  Icons.check_outlined,
                                                  color: TPColors.white,
                                                ),
                                              ],
                                            ),
                                          false =>
                                            Assets.svg.iconUnchecked.svg(),
                                        },
                                      ],
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
