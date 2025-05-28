import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:town_pass/util/tp_text_span.dart';

export 'package:town_pass/util/tp_text_styles.dart';

class TPText extends StatelessWidget {
  /// The text to display.
  ///
  /// This will be null if a [textSpan] is provided instead.
  final String? data;

  /// The text to display as a [InlineSpan].
  ///
  /// This will be null if [data] is provided instead.
  final InlineSpan? textSpan;

  /// If non-null, the style to use for this text.
  ///
  /// If the style's "inherit" property is true, the style will be merged with
  /// the closest enclosing [DefaultTextStyle]. Otherwise, the style will
  /// replace the closest enclosing [DefaultTextStyle].
  final TextStyle? style;

  /// {@macro flutter.painting.textPainter.strutStyle}
  final StrutStyle? strutStyle;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// The directionality of the text.
  ///
  /// This decides how [textAlign] values like [TextAlign.start] and
  /// [TextAlign.end] are interpreted.
  ///
  /// This is also used to disambiguate how to render bidirectional text. For
  /// example, if the [data] is an English phrase followed by a Hebrew phrase,
  /// in a [TextDirection.ltr] context the English phrase will be on the left
  /// and the Hebrew phrase to its right, while in a [TextDirection.rtl]
  /// context, the English phrase will be on the right and the Hebrew phrase on
  /// its left.
  ///
  /// Defaults to the ambient [Directionality], if any.
  final TextDirection? textDirection;

  /// Used to select a font when the same Unicode character can
  /// be rendered differently, depending on the locale.
  ///
  /// It's rarely necessary to set this property. By default its value
  /// is inherited from the enclosing app with `Localizations.localeOf(context)`.
  ///
  /// See [RenderParagraph.locale] for more information.
  final Locale? locale;

  /// Whether the text should break at soft line breaks.
  ///
  /// If false, the glyphs in the text will be positioned as if there was unlimited horizontal space.
  final bool? softWrap;

  /// How visual overflow should be handled.
  ///
  /// If this is null [TextStyle.overflow] will be used, otherwise the value
  /// from the nearest [DefaultTextStyle] ancestor will be used.
  final TextOverflow? overflow;

  /// {@macro flutter.painting.textPainter.textScaler}
  final TextScaler? textScaler;

  /// An optional maximum number of lines for the text to span, wrapping if necessary.
  /// If the text exceeds the given number of lines, it will be truncated according
  /// to [overflow].
  ///
  /// If this is 1, text will not wrap. Otherwise, text will be wrapped at the
  /// edge of the box.
  ///
  /// If this is null, but there is an ambient [DefaultTextStyle] that specifies
  /// an explicit number for its [DefaultTextStyle.maxLines], then the
  /// [DefaultTextStyle] value will take precedence. You can use a [RichText]
  /// widget directly to entirely override the [DefaultTextStyle].
  final int? maxLines;

  /// {@template flutter.widgets.Text.semanticsLabel}
  /// An alternative semantics label for this text.
  ///
  /// If present, the semantics of this widget will contain this value instead
  /// of the actual text. This will overwrite any of the semantics labels applied
  /// directly to the [TextSpan]s.
  ///
  /// This is useful for replacing abbreviations or shorthands with the full
  /// text value:
  ///
  /// ```dart
  /// const Text(r'$$', semanticsLabel: 'Double dollars')
  /// ```
  /// {@endtemplate}
  final String? semanticsLabel;

  /// {@macro flutter.painting.textPainter.textWidthBasis}
  final TextWidthBasis? textWidthBasis;

  /// {@macro dart.ui.textHeightBehavior}
  final TextHeightBehavior? textHeightBehavior;

  /// The color to use when painting the selection.
  ///
  /// This is ignored if [SelectionContainer.maybeOf] returns null
  /// in the [BuildContext] of the [Text] widget.
  ///
  /// If null, the ambient [DefaultSelectionStyle] is used (if any); failing
  /// that, the selection color defaults to [DefaultSelectionStyle.defaultColor]
  /// (semi-transparent grey).
  final Color? selectionColor;

  /// The color to use on text.
  final Color? color;

  /// A pointer has stopped contacting the screen, which is recognized as a tap
  /// of a primary button.
  ///
  /// This triggers on the up event, if the recognizer wins the arena with it
  /// or has previously won, immediately following [onTapUp].
  ///
  /// If this recognizer doesn't win the arena, [onTapCancel] is called instead.
  ///
  /// See also:
  ///
  ///  * [kPrimaryButton], the button this callback responds to.
  ///  * [onSecondaryTap], a similar callback but for a secondary button.
  ///  * [onTapUp], which has the same timing but with details.
  ///  * [GestureDetector.onTap], which exposes this callback.
  final GestureTapCallback? onTap;

  /// Creates a text widget.
  ///
  /// Recommend used with [TPTextStyle] and [TPColor] to make the App looks
  /// more cohesive, example:
  /// ```
  /// TPText(
  ///   'string',
  ///   style: TPTextStyle.bodyRegular,
  ///   color: TPColor.primary500,
  /// )
  /// ```
  ///
  /// If the [style] argument is null, the text will use the style from the
  /// closest enclosing [DefaultTextStyle].
  ///
  /// The [overflow] property's behavior is affected by the [softWrap] argument.
  /// If the [softWrap] is true or null, the glyph causing overflow, and those
  /// that follow, will not be rendered. Otherwise, it will be shown with the
  /// given overflow option.
  const TPText(
    this.data, {
    super.key,
    this.style,
    this.color,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.onTap,
  }) : textSpan = null;

  const TPText.rich(
    this.textSpan, {
    super.key,
    this.style,
    this.strutStyle,
    this.textAlign,
    this.textDirection,
    this.locale,
    this.softWrap,
    this.overflow,
    this.textScaler,
    this.maxLines,
    this.semanticsLabel,
    this.textWidthBasis,
    this.textHeightBehavior,
    this.selectionColor,
    this.color,
    this.onTap,
  }) : data = null;

  TapGestureRecognizer? get gestureRecognizer => switch (onTap) {
        GestureTapCallback onTap => TapGestureRecognizer()..onTap = onTap,
        null => null,
      };

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      switch (textSpan) {
        InlineSpan textSpan => TPTextSpan(
            children: [textSpan],
            recognizer: gestureRecognizer,
          ),
        null => TPTextSpan(
            text: data,
            recognizer: gestureRecognizer,
          ),
      },
      key: key,
      strutStyle: strutStyle,
      textAlign: textAlign,
      textDirection: textDirection,
      locale: locale,
      softWrap: softWrap,
      overflow: overflow,
      textScaler: textScaler,
      maxLines: maxLines,
      semanticsLabel: semanticsLabel,
      textWidthBasis: textWidthBasis,
      textHeightBehavior: textHeightBehavior,
      selectionColor: selectionColor,
      style: switch (style) {
        TextStyle style => switch (color) {
            Color color => style.copyWith(color: color),
            null => style,
          },
        null => TextStyle(color: color),
      },
    );
  }
}

Size textSize(
  String text, {
  TextStyle? style,
  textAlign = TextAlign.start,
  TextDirection? textDirection = TextDirection.ltr,
  TextScaler textScaler = TextScaler.noScaling,
  int? maxLines,
  StrutStyle? strutStyle,
  TextWidthBasis textWidthBasis = TextWidthBasis.parent,
  TextHeightBehavior? textHeightBehavior,
}) {
  final TextPainter textPainter = TextPainter(
    text: TPTextSpan(
      text: text,
      style: style,
    ),
    textAlign: textAlign,
    textDirection: textDirection,
    textScaler: textScaler,
    maxLines: maxLines,
    strutStyle: strutStyle,
    textWidthBasis: textWidthBasis,
    textHeightBehavior: textHeightBehavior,
  )..layout(
      minWidth: 0,
      maxWidth: double.infinity,
    );

  return textPainter.size;
}
