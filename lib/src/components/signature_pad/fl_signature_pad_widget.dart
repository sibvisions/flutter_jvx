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

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlSignaturePadWidget extends FlStatelessWidget<FlCustomContainerModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SignatureController controller;
  final double? width;
  final double? height;
  final DataRecord? dataRecord;
  final VoidCallback? onClear;
  final VoidCallback? onDone;
  final bool showControls;

  const FlSignaturePadWidget({
    super.key,
    required super.model,
    required this.controller,
    required this.showControls,
    this.width,
    this.height,
    this.dataRecord,
    this.onClear,
    this.onDone,
  });

  @override
  Widget build(BuildContext context) {
    Widget? contentWidget;

    if (dataRecord != null && dataRecord?.values[0] != null) {
      var imageValue = dataRecord?.values[0];
      try {
        if (imageValue is String) {
          contentWidget = ImageLoader.loadImage(
            imageValue,
            imageProvider: ImageLoader.getImageProvider(imageValue, pImageInBase64: true),
            pFit: BoxFit.scaleDown,
          );
        } else if (imageValue is Uint8List) {
          contentWidget = Image.memory(imageValue, fit: BoxFit.scaleDown);
        }
      } catch (error, stacktrace) {
        FlutterUI.logUI.e("Failed to show image", error, stacktrace);
      }
    }

    contentWidget ??= Signature(
      width: width,
      height: height,
      controller: controller,
      backgroundColor: Colors.transparent,
    );

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: JVxColors.COMPONENT_BORDER),
        borderRadius: BorderRadius.circular(5),
        color: model.background ?? Colors.white.withOpacity(0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Stack(
          children: [
            Positioned.fill(child: contentWidget),
            if (showControls && (onClear != null || onDone != null))
              Positioned(
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (onClear != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: onClear,
                        ),
                      ),
                    if ((onClear != null) && (onDone != null && contentWidget is Signature)) const SizedBox(width: 5),
                    if (onDone != null && contentWidget is Signature)
                      Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.check),
                          onPressed: onDone,
                        ),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

enum SignatureContextMenuCommand { DONE, CLEAR }
