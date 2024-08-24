part of 'package:town_pass/page/message/message_view.dart';

class _MessageListRow extends StatelessWidget {
  final MessageItem item;

  const _MessageListRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => Get.toNamed(TPRoute.messageDetail, arguments: item),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16, bottom: 5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: switch (item.hasRead) {
                                true => TPColors.primary100,
                                false => TPColors.primary500,
                              },
                            ),
                            const SizedBox(width: 16),
                            Flexible(
                              child: TPText(
                                item.title,
                                style: TPTextStyles.h3SemiBold,
                                color: switch (item.hasRead) {
                                  true => TPColors.grayscale500,
                                  false => TPColors.grayscale800,
                                },
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            const SizedBox(width: 16),
                            TPText(
                              item.datetime.format(),
                              style: TPTextStyles.h3SemiBold,
                              color: switch (item.hasRead) {
                                true => TPColors.grayscale400,
                                false => TPColors.grayscale500,
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Assets.svg.iconExpand.svg(),
              ],
            ),
          ),
          const SizedBox(height: 5),
          const TPLine.horizontal(),
        ],
      ),
    );
  }
}
