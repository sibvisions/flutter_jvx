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
import '../base_wrapper/fl_stateful_widget.dart';

class FlSignaturePadWidget extends FlStatefulWidget<FlCustomContainerModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SignatureController controller;
  final double? width;
  final double? height;
  final DataRecord? dataRecord;
  final VoidCallback? onClear;
  final VoidCallback? onDone;

  const FlSignaturePadWidget({
    super.key,
    required super.model,
    required this.controller,
    this.width,
    this.height,
    this.dataRecord,
    this.onClear,
    this.onDone,
  });

  @override
  State<FlSignaturePadWidget> createState() => _FlSignaturePadWidgetState();
}

class _FlSignaturePadWidgetState extends State<FlSignaturePadWidget> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool currentlyDrawing = false;

  bool _editEnabled = false;

  bool get isEditingPossible => _editEnabled || !widget.model.editLock;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  initState() {
    super.initState();

    widget.controller.onDrawStart = drawStart;
    widget.controller.onDrawEnd = drawEnd;
  }

  @override
  Widget build(BuildContext context) {
    Widget? contentWidget;

    if (widget.dataRecord != null && widget.dataRecord?.values[0] != null) {
      var imageValue = widget.dataRecord?.values[0];
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
      width: widget.width,
      height: widget.height,
      controller: widget.controller,
      backgroundColor: Colors.transparent,
    );

    bool locked = widget.model.saveLock && contentWidget is! Signature;

    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: JVxColors.COMPONENT_BORDER),
        borderRadius: BorderRadius.circular(4),
        color: widget.model.background ?? Colors.white.withOpacity(0.7),
      ),
      child: Padding(
        padding: const EdgeInsets.all(3.0),
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                ignoring: widget.model.editLock && !_editEnabled,
                child: contentWidget,
              ),
            ),
            if (widget.model.saveLock && !currentlyDrawing)
              Positioned(
                child: Padding(
                  padding: const EdgeInsets.all(5),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      locked ? Icons.lock : Icons.lock_open,
                    ),
                  ),
                ),
              ),
            if (!currentlyDrawing && !locked)
              Positioned(
                right: 0,
                bottom: 0,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.onClear != null && isEditingPossible)
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            padding: const EdgeInsets.all(8.0),
                            icon: const Icon(Icons.clear),
                            onPressed: widget.onClear,
                          ),
                        ),
                      ),
                    if (widget.onDone != null && contentWidget is Signature && isEditingPossible)
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            padding: const EdgeInsets.all(8.0),
                            icon: const Icon(Icons.check),
                            onPressed: _onDone,
                          ),
                        ),
                      ),
                    if (widget.model.editLock && (!_editEnabled || contentWidget is! Signature))
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: IconButton(
                            padding: const EdgeInsets.all(8.0),
                            icon: _editEnabled ? const Icon(Icons.edit_off) : const Icon(Icons.edit),
                            onPressed: editSwitch,
                          ),
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

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  void _onDone() {
    widget.onDone?.call();
    _editEnabled = false;
  }

  void editSwitch() {
    _editEnabled = !_editEnabled;

    setState(() {});
  }

  void drawStart() {
    currentlyDrawing = true;
    setState(() {});
  }

  void drawEnd() {
    currentlyDrawing = false;
    setState(() {});
  }
}

enum SignatureContextMenuCommand { DONE, CLEAR }
