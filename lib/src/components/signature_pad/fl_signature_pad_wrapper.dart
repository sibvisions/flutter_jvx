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
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signature/signature.dart';

import '../../flutter_ui.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/command/base_command.dart';
import '../../model/component/custom/fl_custom_container_model.dart';
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
      showImage: _dataRecord?.values.isNotEmpty == true && _dataRecord?.values[0] != null,
      dataRecord: _dataRecord,
      onLongPress: showContextMenu,
      onLongPressDown: (details) => this.details = details,
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

      List<dynamic> values = [];
      values.add(pngBytes);

      FlutterUI.logUI.i("Sending Signature");

      return [
        SetValuesCommand(
            componentId: model.id,
            dataProvider: model.dataProvider!,
            editorColumnName: model.columnName,
            columnNames: [model.columnName!],
            values: values,
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

  showContextMenu() {
    if (details == null) {
      return;
    }

    List<PopupMenuEntry<SignatureContextMenuCommand>> popupMenuEntries =
        <PopupMenuEntry<SignatureContextMenuCommand>>[];

    if (_dataRecord?.values[0] == null) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.squarePlus, "Done", SignatureContextMenuCommand.DONE));
    }
    popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.squareMinus, "Clear", SignatureContextMenuCommand.CLEAR));

    showMenu(
            position: RelativeRect.fromRect(
                details!.globalPosition & const Size(40, 40), Offset.zero & MediaQuery.of(context).size),
            context: context,
            items: popupMenuEntries)
        .then((val) {
      if (val != null) {
        IUiService()
            .saveAllEditors(
                pId: model.id,
                pFunction: () async {
                  if (val == SignatureContextMenuCommand.DONE) {
                    return await sendSignature();
                  } else if (val == SignatureContextMenuCommand.CLEAR) {
                    return await deleteSignature();
                  }
                  return [];
                },
                pReason: "Signature pad closed.")
            .catchError(IUiService().handleAsyncError);
      }
    });
  }

  PopupMenuItem<SignatureContextMenuCommand> _getContextMenuItem(
      IconData icon, String text, SignatureContextMenuCommand value) {
    return PopupMenuItem<SignatureContextMenuCommand>(
      enabled: true,
      value: value,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FaIcon(
            icon,
            color: Colors.grey[600],
          ),
          Padding(padding: const EdgeInsets.only(left: 5), child: Text(text)),
        ],
      ),
    );
  }
}
