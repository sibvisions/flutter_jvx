import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

import '../../../../../flutterclient.dart';

class QrCodeViewWidget extends StatefulWidget {
  @override
  _QrCodeViewWidgetState createState() => _QrCodeViewWidgetState();
}

class _QrCodeViewWidgetState extends State<QrCodeViewWidget> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  late QRViewController _controller;

  void _onQRViewCreated(QRViewController controller) {
    _controller = controller;
    _controller.scannedDataStream.listen((scanData) {
      bool isCurrent = ModalRoute.of(context)?.isCurrent ?? false;
      if (mounted && isCurrent) Navigator.of(context).pop(scanData);
    });
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return Scaffold(
      appBar: AppBar(
        iconTheme:
            IconThemeData(color: Theme.of(context).primaryColor.textColor()),
        title: Text(
          'Scan QR',
          style: TextStyle(color: Theme.of(context).primaryColor.textColor()),
        ),
      ),
      body: Column(
        children: [
          Expanded(
              flex: 5,
              child: QRView(
                key: qrKey,
                onQRViewCreated: _onQRViewCreated,
                overlay: QrScannerOverlayShape(
                    borderColor: Theme.of(context).primaryColor,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: scanArea),
              )),
        ],
      ),
    );
  }
}
