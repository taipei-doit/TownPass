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

  TextSpan _rich(List<TPRichText> richText) {
    return TextSpan(
      children: richText
          .map(
            (object) => TextSpan(
              text: object.text ?? object.url,
              style: switch (object.style?.contains(TPRichTextStyle.bold)) {
                true => TPTextStyles.h3SemiBold,
                _ => TPTextStyles.h3Regular,
              }
                  .copyWith(
                color: switch (object.url) {
                  String() => TPColors.primary500,
                  null => TPColors.grayscale800,
                },
                decoration: switch (object.url) {
                  String() => TextDecoration.underline,
                  null => switch (object.style?.contains(TPRichTextStyle.underline)) {
                      true => TextDecoration.underline,
                      _ => TextDecoration.none,
                    }
                },
                decorationColor: switch (object.url) {
                  String() => TPColors.primary500,
                  null => TPColors.grayscale800,
                },
                fontStyle: switch (object.style?.contains(TPRichTextStyle.italic)) {
                  true => FontStyle.italic,
                  _ => FontStyle.normal,
                },
              ),
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
}
