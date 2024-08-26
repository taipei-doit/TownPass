import 'package:collection/collection.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/city_service/model/my_service_model.dart';
import 'package:town_pass/page/city_service/widget/pinned_service_item_widget.dart';
import 'package:town_pass/page/city_service/widget/pinned_service_widget_controller.dart';
import 'package:town_pass/util/extension/list.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_text.dart';

class PinnedServiceWidget extends GetView<PinnedServiceWidgetController> {
  final GestureTapCallback? onMoreTap;
  final bool isEditMode;
  final bool showAddInNewLine;

  const PinnedServiceWidget({
    super.key,
    this.onMoreTap,
    this.isEditMode = false,
    this.showAddInNewLine = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () {
        return Table(
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
            2: FlexColumnWidth(),
            3: FlexColumnWidth(),
          },
          children: (List.from(controller.pinnedList)
                ..addIf(
                  _appendAddButtonOrNot,
                  _AddMoreButton(onTap: onMoreTap),
                ))
              .splitBetweenIndexed(
                (index, _, __) => index % 4 == 0,
              )
              .map<TableRow>(
                (rowList) {
                  return TableRow(
                    children: rowList.map<Widget>(
                      (itemId) {
                        if (itemId is MyServiceItemId) {
                          return PinnedServiceItemWidget(
                            service: itemId.item,
                            isEdit: isEditMode,
                            onTap: switch (isEditMode) {
                              true => (() => controller.pinnedList.remove(itemId)),
                              false => null,
                            },
                          );
                        }
                        return itemId;
                      },
                    ).toList()
                      ..addAllIf(
                        rowList.length < 4,
                        List.filled(4 - rowList.length, const SizedBox.shrink()),
                      ),
                  );
                },
              )
              .toList()
              .joined(
                TableRow(
                  children: List.filled(4, const SizedBox(height: 16)),
                ),
              ),
        );
      },
    );
  }

  bool get _appendAddButtonOrNot {
    return !isEditMode && controller.pinnedList.length < 12 && (showAddInNewLine ? true : controller.pinnedList.length % 4 != 0);
  }
}

class _AddMoreButton extends StatelessWidget {
  final GestureTapCallback? onTap;

  const _AddMoreButton({this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap?.call(),
      child: Column(
        children: [
          Assets.svg.iconAdd.svg(),
          const SizedBox(height: 4),
          const TPText(
            '新增',
            style: TPTextStyles.bodySemiBold,
            color: TPColors.grayscale700,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
