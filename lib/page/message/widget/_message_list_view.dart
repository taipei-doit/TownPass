part of 'package:town_pass/page/message/message_view.dart';

class MessageListView extends GetView<MessageViewController> {
  final MessageType messageType;

  const MessageListView({
    super.key,
    required this.messageType,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.isLoading && (controller.messageList(type: messageType).isEmpty)) {
        return const ColoredBox(
          color: TPColors.white,
          child: _EmptyMessageWidget(),
        );
      }
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                const TPText(
                  '最新消息',
                  style: TPTextStyles.h3SemiBold,
                  color: TPColors.grayscale700,
                ),
                const Spacer(),
                Builder(
                    builder: (context) {
                      final int unreadCount = controller.unreadCount(type: messageType);
                      return TPText(
                        '全部已讀($unreadCount)',
                        style: TPTextStyles.h3Regular,
                        color: switch (unreadCount) {
                          0 => TPColors.grayscale700,
                          _ => TPColors.primary500,
                        },
                      );
                    }
                ),
              ],
            ),
          ),
          Expanded(
            child: ColoredBox(
              color: TPColors.white,
              child: ListView.builder(
                itemCount: controller.messageList(type: messageType).length,
                itemBuilder: (_, index) => _MessageListRow(
                  item: controller.messageList(type: messageType)[index],
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}
