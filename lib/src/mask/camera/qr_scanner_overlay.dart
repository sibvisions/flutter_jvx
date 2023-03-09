/* 
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../flutter_ui.dart';

/// Definition of the callback for the QR-scanner.
///
/// In case of [allowMultiScan], this can returns multiple barcodes.
typedef QRCallback = FutureOr<void> Function(List<Barcode> barcode);

/// Displays the QR-Scanner with additional a control bar on top.
class QRScannerOverlay extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This callback will be called with the barcode data.
  final QRCallback callback;
  final bool allowMultiScan;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const QRScannerOverlay({
    super.key,
    required this.callback,
    this.allowMultiScan = false,
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<QRScannerOverlay> createState() => _QRScannerOverlayState();
}

/// State is needed for disposing the controller.
class _QRScannerOverlayState extends State<QRScannerOverlay> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for the camera.
  MobileScannerController controller = MobileScannerController();
  bool multiScanEnabled = false;
  final List<Barcode> scannedBarcodes = [];

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Navigator.canPop(context)
            ? IconButton(
                icon: const FaIcon(FontAwesomeIcons.lessThan),
                onPressed: () async {
                  var result = widget.callback(scannedBarcodes);
                  if (result is Future) await result;
                  if (mounted) {
                    Navigator.pop(context);
                  }
                },
              )
            : null,
        title: Text(FlutterUI.translate("QR Scanner")),
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
          if (widget.allowMultiScan)
            PopupMenuButton(
              onSelected: (value) => setState(() => multiScanEnabled = !multiScanEnabled),
              itemBuilder: (context) {
                return [
                  CheckedPopupMenuItem(
                    checked: multiScanEnabled,
                    value: 0,
                    padding: EdgeInsets.zero,
                    child: Text(FlutterUI.translate("Multi Scan")),
                  ),
                ];
              },
            )
        ],
      ),
      body: MobileScanner(
        allowDuplicates: multiScanEnabled,
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

  _onDetect(Barcode barcode, MobileScannerArguments? mobileScannerArguments) async {
    if (multiScanEnabled) {
      if (scannedBarcodes.none((e) => e.rawValue == barcode.rawValue)) {
        unawaited(HapticFeedback.vibrate());
        scannedBarcodes.add(barcode);
      }
    } else {
      unawaited(HapticFeedback.vibrate());
      var result = widget.callback([barcode]);
      if (result is Future) await result;
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }
}
