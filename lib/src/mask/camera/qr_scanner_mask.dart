import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerMask extends StatefulWidget {

  QRScannerMask({
    Key? key,
    required this.callBack
  }) : super(key: key);

  /// This callback will be called with the barcode data
  final Function callBack;

  @override
  State<QRScannerMask> createState() => _QRScannerMaskState();
}

/// State is needed for disposing the controller
class _QRScannerMaskState extends State<QRScannerMask> {

  /// Controller for the camera
  MobileScannerController controller = MobileScannerController();

  bool detected = false;

  _onDetect(Barcode barcode, dynamic mobileScannerArguments) {
    if(!detected){
      detected = true;
      widget.callBack(barcode);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("QR Scanner"),),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
      ),
    );
  }
}
