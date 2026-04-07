/*
 * Copyright 2022-2023 SIB Visions GmbH
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

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../flutter_ui.dart';
import '../haptic_util.dart';
import '../jvx_colors.dart';

/// Definition of the callback for the Scanner.
///
/// In case of [EmbeddedCodeScanner.allowMultiScan], this can returns multiple barcodes.
typedef ScannerCallback = FutureOr<void> Function(List<Barcode> barcode);

/// Displays a Scanner with an additional control bar on top.
class EmbeddedCodeScanner extends StatefulWidget {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// This callback will be called with the barcode data.
  final ScannerCallback callback;
  final bool allowMultiScan;
  final String? title;
  final List<BarcodeFormat> formats;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const EmbeddedCodeScanner({
    super.key,
    required this.callback,
    this.allowMultiScan = true,
    this.title,
    this.formats = const [BarcodeFormat.all]
  });

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  State<EmbeddedCodeScanner> createState() => _EmbeddedCodeScannerState();
}

class _EmbeddedCodeScannerState extends State<EmbeddedCodeScanner> with SingleTickerProviderStateMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Controller for the scanner.
  late final MobileScannerController controller;
  final List<Barcode> scannedBarcodes = [];

  /// whether scan is already done
  bool _scanDone = false;

  bool _multiScanEnabled = false;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();

    controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      formats: widget.formats,
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Orientation orientation = MediaQuery.of(context).orientation;

    final Rect scanWindow = Rect.fromCenter(
      center: MediaQuery.sizeOf(context).center(Offset.zero),
      width: _multiScanEnabled ? (orientation == Orientation.landscape ? 500 : 250) : 250,
      height: _multiScanEnabled ? (orientation == Orientation.landscape ? 250 : 500) : 250,
    );

    EdgeInsets padding = MediaQuery.viewPaddingOf(context);



    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarContrastEnforced: false
      ),
      child: Stack(
        children: [
          Container(color: Colors.black),

          MobileScanner(
            fit: BoxFit.cover,
            controller: controller,
            onDetect: _onDetect,
            scanWindow: scanWindow,
          ),

          CustomPaint(
            painter: ScannerPainter(
              height: scanWindow.height,
              width: scanWindow.width
            ),
            child: Container(),
          ),

          Positioned(top: padding.top + 10,
            right: padding.right + (orientation == Orientation.portrait ? 20 : 10),
            child: CloseButton(
              style: IconButton.styleFrom(
                backgroundColor: Colors.white70,
                shape: const CircleBorder(),
              )
            )
          ),

          Positioned(top: padding.top + 10,
            left: padding.left + (orientation == Orientation.portrait ? 20 : 10),
            child: ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, state, child) {
                return IconButton(
                  tooltip: FlutterUI.translate(state.torchState == TorchState.off ? "Enable Torch" : "Disable Torch"),
                  onPressed: () => controller.toggleTorch(),
                  icon: Icon(_getTorchIcon(state.torchState)),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white70,
                    shape: const CircleBorder(),
                  )
                );
              },
            )
          ),

          if (widget.allowMultiScan)
            Positioned(top: padding.top + 10 + (orientation == Orientation.landscape ? 50 : 0),
              left: padding.left + (orientation == Orientation.portrait ? 70 : 10),
              child: IconButton(
                  tooltip: FlutterUI.translate(_multiScanEnabled ? "Disable multiscan" : "Enable multiscan"),
                onPressed: () {
                  setState(() {
                    _multiScanEnabled = !_multiScanEnabled;
                  });
                },
                icon: Icon(_multiScanEnabled ? Icons.dashboard_customize_outlined : Icons.qr_code),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor: _multiScanEnabled ? Colors.white70 : Colors.white12,
                  iconColor: _multiScanEnabled ? null : Colors.black54,
                  shape: const CircleBorder(),
                ),
              )
            ),

          Positioned(
            bottom: padding.bottom + 5,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                FlutterUI.translate(widget.title ?? (_multiScanEnabled ? "Scan codes" : "Scan code")),
                style: TextStyle(color: JVxColors.DARKER_WHITE,
                  decoration: TextDecoration.none,
                  fontSize: 20),
              )
            )
          )
        ],
      )
    );
  }

  IconData _getTorchIcon(TorchState state) {
    switch (state) {
      case TorchState.unavailable:
        return Icons.block;
      case TorchState.off:
        return Icons.flash_off;
      case TorchState.on:
        return Icons.flash_on;
      case TorchState.auto:
            return Icons.flash_auto;
    }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  Future<void> _onDetect(BarcodeCapture capture) async {
    Iterable<Barcode> newCodes;

    //guaranteed: only one scan in single-scan mode
    if (!_multiScanEnabled) {
      if (_scanDone) {
        return;
      }

      _scanDone = true;

      //removes duplicates
      newCodes = capture.barcodes.toSet();

      scannedBarcodes.addAll(newCodes);
    }
    else {
      //removes duplicates
      Set<Barcode> scanned = scannedBarcodes.toSet();

      //Keep only codes which are not available in already scanned cods
      newCodes = capture.barcodes.where((barcode) => !scanned.contains(barcode));

      scanned.addAll(newCodes);
    }

    if (newCodes.isNotEmpty) {
      await HapticUtil.vibrate();

      var result = widget.callback(newCodes.toList(growable: false));
      if (result is Future) await result;

      if (!_multiScanEnabled && mounted) {
        Navigator.pop(context);
      }
    }
  }
}

class ScannerPainter extends CustomPainter {
  final double width;
  final double height;

  ScannerPainter({double? width,
    double? height}):
      width = width ?? 250,
      height = height ?? 250;

  @override
  void paint(Canvas canvas, Size size) {
    final double scanAreaWidth = width;
    final double scanAreaHeight = height;
    final double borderRadius = 24.0;
    final double borderLength = 40.0;
    final double strokeWidth = 6.0;

    final backgroundPaint = Paint()..color = Colors.black.withAlpha(153);

    final scanRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaWidth,
      height: scanAreaHeight,
    );

    // Draw dark overlay around scan rect
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(Rect.fromLTWH(0, 0, size.width, size.height)),
        Path()..addRRect(RRect.fromRectAndRadius(scanRect, Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    // white colored corner
    final cornerPaint = Paint()
      ..color = JVxColors.DARKER_WHITE
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final double left = scanRect.left;
    final double top = scanRect.top;
    final double right = scanRect.right;
    final double bottom = scanRect.bottom;

    // Path for corner
    final Path cornersPath = Path();

    // top left
    cornersPath.moveTo(left, top + borderLength);
    cornersPath.lineTo(left, top + borderRadius);
    cornersPath.arcToPoint(Offset(left + borderRadius, top), radius: Radius.circular(borderRadius));
    cornersPath.lineTo(left + borderLength, top);

    // top right
    cornersPath.moveTo(right - borderLength, top);
    cornersPath.lineTo(right - borderRadius, top);
    cornersPath.arcToPoint(Offset(right, top + borderRadius), radius: Radius.circular(borderRadius));
    cornersPath.lineTo(right, top + borderLength);

    // bottom right
    cornersPath.moveTo(right, bottom - borderLength);
    cornersPath.lineTo(right, bottom - borderRadius);
    cornersPath.arcToPoint(Offset(right - borderRadius, bottom), radius: Radius.circular(borderRadius));
    cornersPath.lineTo(right - borderLength, bottom);

    // bottom left
    cornersPath.moveTo(left + borderLength, bottom);
    cornersPath.lineTo(left + borderRadius, bottom);
    cornersPath.arcToPoint(Offset(left, bottom - borderRadius), radius: Radius.circular(borderRadius));
    cornersPath.lineTo(left, bottom - borderLength);

    canvas.drawPath(cornersPath, cornerPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

