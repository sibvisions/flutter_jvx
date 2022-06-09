import 'dart:developer';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/model/command/api/set_values_command.dart';
import 'package:flutter_client/src/model/component/custom/fl_custom_container_model.dart';
import 'package:signature/signature.dart';

import '../../model/data/subscriptions/data_chunk.dart';
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

  DataChunk? _chunkData;
  late final SignatureController signatureController;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Overridden methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    final FlSignaturePadWidget widget = FlSignaturePadWidget(model: model, controller: signatureController);

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
    signatureController = SignatureController(onDrawEnd: () => onEndDrawing());

    super.initState();
    subscribe();
    layoutData.isFixedSize = true;
  }

  @override
  void receiveNewModel({required FlCustomContainerModel newModel}) {
    super.receiveNewModel(newModel: newModel);
    unsubscribe();
    subscribe();
  }

  Future<void> onEndDrawing() async {
    Uint8List? pngBytes = await signatureController.toPngBytes();

    List<dynamic> values = [];
    values.add(pngBytes);

    log("Drawing ended");

    SetValuesCommand setValues = SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: getDataColumns(),
        values: values,
        reason: "Drawing has ended on ${model.id}");
    uiService.sendCommand(setValues);

    setState(() {});
  }

  void subscribe() {
    uiService.registerDataSubscription(
      pDataSubscription: DataSubscription(
        id: model.id,
        from: -1,
        dataProvider: model.dataProvider,
        onDataChunk: receiveSignatureData,
        dataColumns: getDataColumns(),
      ),
    );
  }

  void unsubscribe() {
    uiService.disposeDataSubscription(pComponentId: model.id, pDataProvider: model.dataProvider);
  }

  void receiveSignatureData(DataChunk pChunkData) {
    if (pChunkData.update && _chunkData != null) {
      for (int index in pChunkData.data.keys) {
        _chunkData!.data[index] = pChunkData.data[index]!;
      }
    } else {
      _chunkData = pChunkData;
    }

    setState(() {});
  }

  List<String> getDataColumns() {
    return [model.columnName];
  }
}
