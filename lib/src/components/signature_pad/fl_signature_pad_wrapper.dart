import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signature/signature.dart';

import '../../../flutter_jvx.dart';
import '../../model/command/api/set_values_command.dart';
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

  const FlSignaturePadWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlSignaturePadWrapperState();
}

class _FlSignaturePadWrapperState extends BaseCompWrapperState<FlCustomContainerModel> {
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Class members
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  DataRecord? _dataRecord;
  late final SignatureController signatureController;
  bool showImage = false;
  LongPressDownDetails? details;

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
// Overridden methods
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    super.initState();
    signatureController = SignatureController();

    showImage = _dataRecord?.values[0] != null;
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
      showImage: showImage,
      sendSignature: sendSignature,
      deleteSignature: deleteSignature,
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
  void receiveNewModel({required FlCustomContainerModel newModel}) {
    super.receiveNewModel(newModel: newModel);
    unsubscribe();
    subscribe();
  }

  Future<void> sendSignature() async {
    Uint8List? pngBytes = await signatureController.toPngBytes();

    List<dynamic> values = [];
    values.add(pngBytes);

    FlutterJVx.log.i("Sending Signature");

    SetValuesCommand setValues = SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: getDataColumns(),
        values: values,
        reason: "Drawing has ended on ${model.id}");
    await IUiService().sendCommand(setValues);
  }

  Future<void> deleteSignature() async {
    FlutterJVx.log.i("Deleting Signature");
    signatureController.clear();

    SetValuesCommand setValues = SetValuesCommand(
        componentId: model.id,
        dataProvider: model.dataProvider,
        columnNames: getDataColumns(),
        values: [],
        reason: "Drawing has ended on ${model.id}");
    await IUiService().sendCommand(setValues);
  }

  void subscribe() {
    IUiService().registerDataSubscription(
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
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  void receiveSignatureData(DataRecord? pDataRecord) {
    _dataRecord = pDataRecord;
    showImage = _dataRecord?.values[0] != null;
    setState(() {});
  }

  List<String> getDataColumns() {
    return [model.columnName];
  }

  showContextMenu() {
    if (details == null) {
      return;
    }

    List<PopupMenuEntry<SignatureContextMenuCommand>> popupMenuEntries =
        <PopupMenuEntry<SignatureContextMenuCommand>>[];

    if (_dataRecord?.values[0] == null) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.squarePlus, 'Done', SignatureContextMenuCommand.DONE));
    }
    popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.squareMinus, 'Clear', SignatureContextMenuCommand.CLEAR));

    showMenu(
            position: RelativeRect.fromRect(
                details!.globalPosition & const Size(40, 40), Offset.zero & MediaQuery.of(context).size),
            context: context,
            items: popupMenuEntries)
        .then((val) {
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
      if (val != null) {
        if (val == SignatureContextMenuCommand.DONE) {
          sendSignature();
        } else if (val == SignatureContextMenuCommand.CLEAR) {
          deleteSignature();
        }
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
        children: <Widget>[
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
