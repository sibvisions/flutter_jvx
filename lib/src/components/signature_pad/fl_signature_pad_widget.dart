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

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../flutter_ui.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../util/image/image_loader.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlSignaturePadWidget extends FlStatelessWidget<FlCustomContainerModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SignatureController controller;
  final double? width;
  final double? height;
  final bool showImage;
  final DataRecord? dataRecord;
  final VoidCallback? onLongPress;
  final Function(LongPressDownDetails?)? onLongPressDown;

  const FlSignaturePadWidget({
    super.key,
    required super.model,
    required this.controller,
    required this.width,
    required this.height,
    required this.showImage,
    this.dataRecord,
    this.onLongPress,
    this.onLongPressDown,
  });

  @override
  Widget build(BuildContext context) {
    Widget? image;
    if (showImage) {
      dynamic imageValue = dataRecord?.values[0];

      if (imageValue != null) {
        try {
          if (imageValue is String && imageValue.startsWith("[")) {
            List<String> listOfSnippets = imageValue.substring(1, imageValue.length - 1).split(",");

            imageValue = Uint8List.fromList(listOfSnippets.map((e) => int.parse(e)).toList());
          }

          if (imageValue is Uint8List) {
            image = Image.memory(imageValue, fit: BoxFit.scaleDown);
          }
        } catch (error, stacktrace) {
          FlutterUI.logUI.e("Failed to show image", error, stacktrace);
        }
      }
      image ??= ImageLoader.DEFAULT_IMAGE;
    }

    return GestureDetector(
      onLongPress: () => onLongPress?.call(),
      onLongPressDown: (details) => onLongPressDown?.call(details),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(5),
          color: model.background ?? Colors.white.withOpacity(0.7),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: image ??
              Signature(
                key: UniqueKey(),
                // TODO Remove after initState fix for width and height
                width: width,
                height: height,
                controller: controller,
                backgroundColor: Colors.transparent,
              ),
        ),
      ),
    );
  }
}

enum SignatureContextMenuCommand { DONE, CLEAR }
