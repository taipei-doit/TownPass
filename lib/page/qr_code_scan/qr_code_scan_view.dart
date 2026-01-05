import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:town_pass/gen/assets.gen.dart';
import 'package:town_pass/page/qr_code_scan/qr_code_scan_controller.dart';
import 'package:town_pass/util/tp_app_bar.dart';
import 'package:town_pass/util/tp_colors.dart';
import 'package:town_pass/util/tp_dialog.dart';
import 'package:town_pass/util/tp_text.dart';

class QRCodeScanView extends GetView<QRCodeScanController> {
  const QRCodeScanView({super.key});

  // 常數定義掃描視窗的尺寸和位置參數。
  // _scanWindowTopRelativeOffsetFactor: 定義掃描視窗頂部相對於螢幕寬度的偏移比例 (0.3)。
  static const double _scanWindowTopRelativeOffsetFactor = 0.3;
  // _scanWindowVerticalFixedOffset: 定義掃描視窗的固定垂直偏移量 (4 + 48 = 52.0)，可能用於調整與其他 UI 元素的距離。
  static const double _scanWindowVerticalFixedOffset = 52.0;
  // _scanWindowSizeFactor: 定義掃描視窗的寬高相對於螢幕寬度的比例 (0.6)。
  static const double _scanWindowSizeFactor = 0.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TPAppBar(
        title: '掃描',
        leading: const SizedBox.shrink(),
        actions: [
          CloseButton(
            onPressed: () => Get.back(),
            style: const ButtonStyle(
              iconSize: WidgetStatePropertyAll<double>(24),
            ),
          ),
        ],
      ),
      backgroundColor: TPColors.transparent,
      body: Stack(
        children: [
          MobileScanner(
            scanWindow: _scanWindow,
            controller: controller.scanController,
            errorBuilder: (context, error, child) {
              return ScannerErrorWidget(error: error);
            },
          ),
          ValueListenableBuilder(
            valueListenable: controller.scanController,
            builder: (context, value, child) {
              if (!value.isInitialized || !value.isRunning || value.error != null || value.size.isEmpty) {
                return const SizedBox();
              }
              return CustomPaint(
                painter: _ScannerOverlay(window: _scanWindow),
              );
            },
          ),
          Positioned(
            top: _scanWindow.bottom + 48,
            left: 0,
            right: 0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const TPText(
                  '請掃描繳費單的 QR Code',
                  style: TPTextStyles.h2SemiBold,
                  color: TPColors.white,
                ),
                const TPText(
                  '或',
                  style: TPTextStyles.h2SemiBold,
                  color: TPColors.white,
                ),
                TPText(
                  '從相片掃描',
                  style: TPTextStyles.h2SemiBold.copyWith(
                    color: TPColors.primary500,
                    decoration: TextDecoration.underline,
                    decorationColor: TPColors.primary500,
                  ),
                  onTap: () async => switch (await controller.scanFromImage()) {
                    null => await TPDialog.showError(title: '錯誤', content: '無法辨識 QR Code'),
                    String string => Get.back(result: string),
                  },
                ),
              ],
            ),
          ),
          Positioned(
            bottom: 32,
            left: 0,
            right: 0,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => TPDialog.showInfo(
                title: '條碼示意圖',
                content: SizedBox(
                  width: Get.width * 0.5,
                  height: Get.width * 0.5,
                  child: Assets.svg.dialogQrCode.svg(),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Assets.svg.info.svg(height: 16, colorFilter: const ColorFilter.mode(TPColors.white, BlendMode.srcIn)),
                  const SizedBox(width: 4),
                  const TPText(
                    '掃描說明',
                    style: TPTextStyles.bodySemiBold,
                    color: TPColors.white,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 計算並回傳 QR Code 掃描視窗的 Rect 範圍。
  /// 此 getter 會根據螢幕寬度及預設的比例和固定偏移量來決定掃描視窗的大小和中心位置。
  Rect get _scanWindow {
    final double screenWidth = Get.width; // 取得螢幕寬度，以便計算相對尺寸
    final double scanWindowWidth = screenWidth * _scanWindowSizeFactor;
    final double scanWindowHeight = scanWindowWidth; // 掃描視窗為正方形

    final double centerX = screenWidth / 2;
    final double centerY = screenWidth * _scanWindowTopRelativeOffsetFactor + _scanWindowVerticalFixedOffset;

    return Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: scanWindowWidth,
      height: scanWindowHeight,
    );
  }
}

class _ScannerOverlay extends CustomPainter {
  _ScannerOverlay({required this.window});

  final Rect window;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPath = Path()..addRect(Rect.largest);
    final cutoutPath = Path()..addRect(window);

    final Paint backgroundPaint = Paint()
      ..color = Colors.black.withOpacity(0.5)
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final Path backgroundWithCutout = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    const double strokeWidth = 5.0;
    final Rect strokeRect = Rect.fromCenter(
      center: window.center,
      width: window.width + strokeWidth,
      height: window.height + strokeWidth,
    );

    final borderPaint = Paint()
      ..color = TPColors.primary500
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double cornerStrokeWidth = window.width / 5;
    final double cornerStrokeHeight = window.height / 5;

    canvas
      ..drawPath(
        Path()
          // top left corner
          ..moveTo(strokeRect.left, strokeRect.top + cornerStrokeHeight)
          ..lineTo(strokeRect.left, window.top)
          ..quadraticBezierTo(strokeRect.left, strokeRect.top, window.left, strokeRect.top)
          ..lineTo(strokeRect.left + cornerStrokeWidth, strokeRect.top)

          // top right corner
          ..moveTo(strokeRect.right - cornerStrokeWidth, strokeRect.top)
          ..lineTo(window.right, strokeRect.top)
          ..quadraticBezierTo(strokeRect.right, strokeRect.top, strokeRect.right, window.top)
          ..lineTo(strokeRect.right, strokeRect.top + cornerStrokeHeight)

          // bottom right
          ..moveTo(strokeRect.right, strokeRect.bottom - cornerStrokeHeight)
          ..lineTo(strokeRect.right, window.bottom)
          ..quadraticBezierTo(strokeRect.right, strokeRect.bottom, window.right, strokeRect.bottom)
          ..lineTo(strokeRect.right - cornerStrokeWidth, strokeRect.bottom)

          // bottom left
          ..moveTo(strokeRect.left + cornerStrokeWidth, strokeRect.bottom)
          ..lineTo(window.left, strokeRect.bottom)
          ..quadraticBezierTo(strokeRect.left, strokeRect.bottom, strokeRect.left, window.bottom)
          ..lineTo(strokeRect.left, strokeRect.bottom - cornerStrokeHeight),
        borderPaint,
      );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class ScannerErrorWidget extends StatelessWidget {
  const ScannerErrorWidget({super.key, required this.error});

  final MobileScannerException error;

  @override
  Widget build(BuildContext context) {
    String errorMessage;

    switch (error.errorCode) {
      case MobileScannerErrorCode.controllerUninitialized:
        errorMessage = 'Controller not ready.';
      case MobileScannerErrorCode.permissionDenied:
        errorMessage = 'Permission denied';
      case MobileScannerErrorCode.unsupported:
        errorMessage = 'Scanning is unsupported on this device';
      default:
        errorMessage = 'Generic Error';
        break;
    }

    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Icon(Icons.error, color: Colors.white),
            ),
            TPText(
              errorMessage,
              style: const TextStyle(color: Colors.white),
            ),
            TPText(
              error.errorDetails?.message ?? '',
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}