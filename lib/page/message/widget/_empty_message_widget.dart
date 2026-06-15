part of 'package:town_pass/page/message/message_view.dart';

class _EmptyMessageWidget extends StatelessWidget {
  const _EmptyMessageWidget();

  // 定義相關尺寸與間距常數，提升程式碼可讀性與維護性
  static const double _imageSize = 160.0;
  static const double _verticalPadding = 8.0;
  static const int _topSpacerFlex = 2;
  static const int _bottomSpacerFlex = 3;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Spacer(flex: _topSpacerFlex),
        SizedBox(
          width: _imageSize,
          height: _imageSize,
          child: Center(child: Assets.svg.bookingL.svg()),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: _verticalPadding),
          child: TPText(
            '目前無訊息',
            style: TPTextStyles.h2SemiBold,
            color: TPColors.primary500,
          ),
        ),
        const TPText(
          '請試試其他關鍵字或篩選分類',
          style: TPTextStyles.bodySemiBold,
          color: TPColors.grayscale400,
        ),
        const Spacer(flex: _bottomSpacerFlex),
      ],
    );
  }
}