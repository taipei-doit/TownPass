import 'package:town_pass/bean/message.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/message/message_view_controller.dart';
import 'package:town_pass/util/extension/datetime.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_line.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_tab_view.dart';
import 'package:town_pass/util/tp_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

part 'package:town_pass/page/message/widget/_empty_message_widget.dart';

part 'package:town_pass/page/message/widget/_message_list_row.dart';

part 'package:town_pass/page/message/widget/_message_list_view.dart';

extension on MessageType {
  String get string {
    return switch (this) {
      MessageType.personal => '個人通知',
      MessageType.tcg => '市府訊息',
      MessageType.system => '系統訊息',
    };
  }
}

class MessageView extends GetView<MessageViewController> {
  const MessageView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: controller.tabTypeList.length,
      child: Scaffold(
        appBar: TPAppBar(
          title: '訊息',
          actions: [
            IconButton(
              icon: Assets.svg.iconTrashClose.svg(),
              onPressed: () {},
            ),
          ],
        ),
        body: TPTabView(
          titles: controller.tabTypeList.map<String>((type) => type.string).toList(),
          children: controller.tabTypeList.map<Widget>((type) => MessageListView(messageType: type)).toList(),
        ),
      ),
    );
  }
}
