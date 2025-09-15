dart
import 'package:flutter/material.dart';

class TPTextSpan extends TextSpan {
  /// The text contained in this span.
  ///
  /// If both [text] and [children] are non-null, the text will precede the
  /// children.
  ///
  /// This getter does not include the contents of its children.
  @override
  final String? text;

  /// Additional spans to include as children.
  ///
  /// If both [text] and [children] are non-null, the text will precede the
  /// children.
  ///
  /// Modifying the list after the [TextSpan] has been created is not supported
  /// and may have unexpected results.
  ///
  /// The list must not contain any nulls.
  @override
  final List<InlineSpan>? children;

  /// split text with words(english characters, digits and "_")
  static final RegExp _splitRegExp = RegExp(r'(?<=\W)(?=\w)|(?<=\w)(?=\W)');

  /// english characters, digits and "_"
  static final RegExp _wordCharacter = RegExp(r'\w');

  TPTextSpan({
    this.text,
    this.children,
    super.style,
    super.recognizer,
    super.mouseCursor,
    super.onEnter,
    super.onExit,
    super.semanticsLabel,
    super.locale,
    super.spellOut,
  }) : super(
          text: null,
          children: [
            ...?text?.split(_splitRegExp).map(_buildTextSpanWithFont),
            ...?children,
          ],
        );

  TextSpan _buildTextSpanWithFont(String text) {
    TextStyle? targetStyle;
    if (text.contains(_wordCharacter)) {
      targetStyle = style?.copyWith(fontFamily: 'Roboto') ?? const TextStyle(fontFamily: 'Roboto');
    } else {
      targetStyle = style?.copyWith(fontFamily: 'PingFangTC') ?? const TextStyle(fontFamily: 'PingFangTC');
    }

    return TextSpan(
      text: text,
      style: targetStyle,
    );
  }
}