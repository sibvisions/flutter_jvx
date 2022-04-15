import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

typedef QRCallback = void Function(Barcode barcode, MobileScannerArguments? arguments);

/// Displays the QR-Scanner with additional a control bar on top
class QRScannerMask extends StatefulWidget {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This callback will be called with the barcode data
  final QRCallback callBack;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const QRScannerMask({
    Key? key,
    required this.callBack
  }) : super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<QRScannerMask> createState() => _QRScannerMaskState();
}

/// State is needed for disposing the controller
class _QRScannerMaskState extends State<QRScannerMask> {

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
        title: const Text("QR SCANNER"),
        actions: [
          IconButton(
              onPressed: () => controller.toggleTorch(),
              icon: ValueListenableBuilder(
                valueListenable: controller.torchState,
                builder: (context, state, child) {
                  switch(state as TorchState){
                    case TorchState.off:
                      return const Icon(Icons.flash_off);
                    case TorchState.on:
                      return const Icon(Icons.flash_on);
                  }
                }
              )
          ),
          const Padding(padding: EdgeInsets.fromLTRB(50, 0, 50, 0)),
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
    widget.callBack(barcode, mobileScannerArguments);

  }

}
