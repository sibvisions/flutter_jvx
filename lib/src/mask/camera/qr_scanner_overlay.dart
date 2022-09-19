import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../flutter_jvx.dart';

/// Definition of the callback for the QR-scanner
typedef QRCallback = void Function(Barcode barcode, MobileScannerArguments? arguments);

/// Displays the QR-Scanner with additional a control bar on top
class QRScannerOverlay extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This callback will be called with the barcode data
  final QRCallback callback;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const QRScannerOverlay({
    Key? key,
    required this.callback,
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

/// State is needed for disposing the controller
class _QRScannerOverlayState extends State<QRScannerOverlay> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for the camera
  MobileScannerController controller = MobileScannerController();

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterJVx.translate("QR Scanner")),
        actions: [
          IconButton(
            onPressed: () => controller.toggleTorch(),
            icon: ValueListenableBuilder(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  switch (state as TorchState) {
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                  }
                }),
          ),
        ],
      ),
      body: MobileScanner(
        controller: controller,
        onDetect: _onDetect,
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _onDetect(Barcode barcode, MobileScannerArguments? mobileScannerArguments) {
    Navigator.of(context).pop();
    widget.callback(barcode, mobileScannerArguments);
  }
}
