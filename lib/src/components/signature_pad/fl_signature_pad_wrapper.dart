import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/command/api/set_values_command.dart';
import 'package:flutter_client/src/model/component/custom/fl_custom_container_model.dart';
import 'package:signature/signature.dart';

import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_signature_pad_widget.dart';

class FlSignaturePadWrapper extends BaseCompWrapperWidget<FlCustomContainerModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlSignaturePadWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlSignaturePadWrapperState createState() => _FlSignaturePadWrapperState();
}

class _FlSignaturePadWrapperState extends BaseCompWrapperState<FlCustomContainerModel> {
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Class members
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataRecord? _dataRecord;
  late final SignatureController signatureController;
  bool showImage = false;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Overridden methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    final FlSignaturePadWidget widget = FlSignaturePadWidget(
      model: model,
      controller: signatureController,
      showImage: showImage,
      sendSignature: sendSignature,
      deleteSignature: deleteSignature,
      dataRecord: _dataRecord,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  Size calculateSize(BuildContext context) {
    return const Size.square(300);
  }

  @override
  void initState() {
    signatureController = SignatureController();

    super.initState();
    subscribe();
    showImage = _dataRecord?.values[0] != null;
    layoutData.isFixedSize = true;
  }

  @override
  void receiveNewModel({required FlCustomContainerModel newModel}) {
    super.receiveNewModel(newModel: newModel);
    unsubscribe();
    subscribe();
  }

  Future<void> sendSignature() async {
    Uint8List? pngBytes = await signatureController.toPngBytes();

    List<dynamic> values = [];
    values.add(pngBytes);

    log("Sending Signature");

    SetValuesCommand setValues = SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: getDataColumns(),
        values: values,
        reason: "Drawing has ended on ${model.id}");
    uiService.sendCommand(setValues);
  }

  Future<void> deleteSignature() async {
    log("Deleting Signature");
    signatureController.clear();

    SetValuesCommand setValues = SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: getDataColumns(),
        values: [],
        reason: "Drawing has ended on ${model.id}");
    uiService.sendCommand(setValues);
  }

  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        from: -1,
        dataProvider: model.dataProvider,
        onSelectedRecord: receiveSignatureData,
        dataColumns: getDataColumns(),
      ),
    );
  }

  void unsubscribe() {
    uiService.disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  void receiveSignatureData(DataRecord? pDataRecord) {
    _dataRecord = pDataRecord;
    showImage = _dataRecord?.values[0] != null;
    setState(() {});
  }

  List<String> getDataColumns() {
    return [model.columnName];
  }
}
