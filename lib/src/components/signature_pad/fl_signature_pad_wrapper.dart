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

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:signature/signature.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../service/ui/i_ui_service.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_signature_pad_widget.dart';

class FlSignaturePadWrapper extends BaseCompWrapperWidget<FlCustomContainerModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlSignaturePadWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlSignaturePadWrapperState();
}

class _FlSignaturePadWrapperState extends BaseCompWrapperState<FlCustomContainerModel> {
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Class members
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  bool showControls = true;
  DataRecord? _dataRecord;
  late final SignatureController signatureController;
  LongPressDownDetails? details;

  _FlSignaturePadWrapperState() : super();
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Overridden methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();
    signatureController = SignatureController();

    signatureController.onDrawStart = () async {
      showControls = false;
      // setState(() { });
    };
    signatureController.onDrawEnd = () async {
      showControls = true;
      // setState(() { });
    };
    layoutData.isFixedSize = true;

    subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlSignaturePadWidget widget = FlSignaturePadWidget(
      model: model,
      controller: signatureController,
      width: getWidthForPositioned(),
      height: getHeightForPositioned(),
      showControls: showControls,
      dataRecord: _dataRecord,
      onClear: _handleClear,
      onDone: _handleDone,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  Size calculateSize(BuildContext context) {
    return const Size.square(300);
  }

  @override
  void modelUpdated() {
    super.modelUpdated();

    unsubscribe();
    subscribe();
  }

  Future<List<BaseCommand>> sendSignature() async {
    if (model.dataProvider != null && model.columnName != null) {
      Uint8List? pngBytes = await signatureController.toPngBytes();

      FlutterUI.logUI.i("Sending Signature");

      return [
        SetValuesCommand(
            componentId: model.id,
            dataProvider: model.dataProvider!,
            editorColumnName: model.columnName,
            columnNames: [model.columnName!],
            values: pngBytes != null ? [base64Encode(pngBytes)] : [null],
            reason: "Drawing has ended on ${model.id}")
      ];
    }
    return List.empty();
  }

  Future<List<BaseCommand>> deleteSignature() async {
    signatureController.clear();

    if (model.dataProvider != null && model.columnName != null) {
      FlutterUI.logUI.i("Deleting Signature");

      return [
        SetValuesCommand(
            componentId: model.id,
            dataProvider: model.dataProvider!,
            editorColumnName: model.columnName,
            columnNames: [model.columnName!],
            values: [],
            reason: "Drawing has ended on ${model.id}"),
      ];
    }
    return List.empty();
  }

  @override
  void dispose() {
    signatureController.dispose();
    super.dispose();
  }

  void subscribe() {
    if (model.dataProvider != null && model.columnName != null) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          dataProvider: model.dataProvider!,
          onSelectedRecord: receiveSignatureData,
          dataColumns: [model.columnName!],
        ),
      );
    }
  }

  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  void receiveSignatureData(DataRecord? pDataRecord) {
    _dataRecord = pDataRecord;
    setState(() {});
  }

  void _handleClear() {
    IUiService()
        .saveAllEditors(
            pId: model.id,
            pFunction: () async {
              return await deleteSignature();
            },
            pReason: "Signature pad closed.")
        .catchError(IUiService().handleAsyncError);
  }

  void _handleDone() {
    IUiService()
        .saveAllEditors(
            pId: model.id,
            pFunction: () async {
              return await sendSignature();
            },
            pReason: "Signature pad closed.")
        .catchError(IUiService().handleAsyncError);
  }
}
