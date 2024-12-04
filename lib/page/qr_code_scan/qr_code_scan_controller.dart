import 'dart:async';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRCodeScanController extends GetxController {
  final MobileScannerController scanController = MobileScannerController(formats: [BarcodeFormat.qrCode]);

  StreamSubscription<BarcodeCapture>? _subscription;

  Future<String?> scanFromImage() async {
    try {
      return switch (switch (await ImagePicker().pickImage(source: ImageSource.gallery)) {
        null => null,
        XFile file => await scanController.analyzeImage(file.path),
      }) {
        null => null,
        BarcodeCapture capture => capture.barcodes.first.displayValue,
      };
    } catch (_) {}
    return null;
  }

  @override
  void onInit() {
    super.onInit();

    _subscription = scanController.barcodes.listen((capture) async {
      await _subscription?.cancel();
      Get.back(result: capture.barcodes.first.displayValue);
    });
  }

  @override
  void dispose() async {
    await scanController.dispose();
    super.dispose();
  }
}
