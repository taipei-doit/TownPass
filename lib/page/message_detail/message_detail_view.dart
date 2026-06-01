```
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:town_pass/bean/message.dart';
import 'package:town_pass/bean/tp_rich_text.dart';
import 'package:town_pass/util/extension/datetime.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_route.dart';
import 'package:town_pass/util/tp_text.dart';

class MessageDetailView extends StatelessWidget {
  MessageItem get item => Get.arguments;

  const MessageDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const TPAppBar(title: '訊息'),
      body: ColoredBox(
        color: TPColors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TPText(
                    item.datetime.format('yyyy/MM/dd HH:mm'),
                    style: TPTextStyles.bodyRegular,
                    color: TPColors.grayscale500,
                  ),
                  const SizedBox(height: 8),
                  TPText(
                    item.title,
                    style: TPTextStyles.h2SemiBold,
                    color: TPColors.grayscale800,
                  ),
                ],
              ),
            ),
            if (item.imageUrl != null) ...[
              const SizedBox(height: 16),
              CachedNetworkImage(imageUrl: item.imageUrl!),
            ],
            if (item.richText != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 21),
                    child: _RichText(
                      richText: item.richText!,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _RichText extends StatelessWidget {
  final List<TPRichText> richText;

  const _RichText({required this.richText});

  @override
  Widget build(BuildContext context) {
    return TPText.rich(_rich(richText));
  }

  /// Generates a TextSpan for a list of TPRichText objects, applying appropriate styles and tap recognizers.
  TextSpan _rich(List<TPRichText> richText) {
    return TextSpan(
      children: richText
          .map(
            (object) => TextSpan(
              text: object.text ?? object.url,
              style: _getTextStyle(object), // 抽取複雜的樣式判斷邏輯到獨立方法
              recognizer: switch (object.url) {
                String uri => TapGestureRecognizer()
                  ..onTap = () async => await TPRoute.openUri(
                        uri: uri,
                      ),
                null => null,
              },
            ),
          )
          .toList(),
    );
  }

  /// Calculates the TextStyle for a given TPRichText object.
  ///
  /// This method encapsulates the logic for determining font weight, color,
  /// decoration, decoration color, and font style based on the TPRichText
  /// properties like URL and contained styles (bold, underline, italic).
  TextStyle _getTextStyle(TPRichText object) {
    // 根據是否包含粗體樣式來決定基礎字體樣式
    TextStyle baseStyle = switch (object.style?.contains(TPRichTextStyle.bold)) {
      true => TPTextStyles.h3SemiBold,
      _ => TPTextStyles.h3Regular,
    };

    // 根據是否為 URL 來決定文字顏色
    final Color textColor = switch (object.url) {
      String() => TPColors.primary500,
      null => TPColors.grayscale800,
    };

    // 根據是否為 URL 或是否包含底線樣式來決定文字裝飾
    final TextDecoration textDecoration = switch (object.url) {
      String() => TextDecoration.underline,
      null => switch (object.style?.contains(TPRichTextStyle.underline)) {
        true => TextDecoration.underline,
        _ => TextDecoration.none,
      }
    };

    // 根據是否包含斜體樣式來決定字體風格
    final FontStyle fontStyle = switch (object.style?.contains(TPRichTextStyle.italic)) {
      true => FontStyle.italic,
      _ => FontStyle.normal,
    };

    // 合併所有計算出的樣式
    return baseStyle.copyWith(
      color: textColor,
      decoration: textDecoration,
      decorationColor: textColor, // 裝飾顏色與文字顏色相同
      fontStyle: fontStyle,
    );
  }
}
```