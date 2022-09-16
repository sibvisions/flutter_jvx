import 'dart:collection';

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../mixin/services.dart';
import '../../../util/extensions/list_extensions.dart';
import '../../../util/logging/flutter_logger.dart';
import '../../../util/parse_util.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/component/editor/fl_editor_model.dart';
import '../../model/component/editor/text_field/fl_text_field_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../model/layout/layout_data.dart';
import '../../model/response/dal_meta_data_response.dart';
import '../../service/api/shared/api_object_property.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import '../base_wrapper/fl_stateless_widget.dart';
import 'cell_editor/date/fl_date_cell_editor.dart';
import 'cell_editor/fl_choice_cell_editor.dart';
import 'cell_editor/fl_dummy_cell_editor.dart';
import 'cell_editor/fl_image_cell_editor.dart';
import 'cell_editor/fl_number_cell_editor.dart';
import 'cell_editor/fl_text_cell_editor.dart';
import 'cell_editor/i_cell_editor.dart';
import 'cell_editor/linked/fl_linked_cell_editor.dart';
import 'text_field/fl_text_field_widget.dart';

/// The [FlEditorWrapper] wraps various cell editors and makes them usable as single wrapped widgets.
/// It serves as the layouting wrapper of various non layouting widgets.
class FlEditorWrapper<T extends FlEditorModel> extends BaseCompWrapperWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlEditorWrapper({Key? key, required String id}) : super(key: key, id: id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlEditorWrapperState createState() => FlEditorWrapperState();
}

class FlEditorWrapperState<T extends FlEditorModel> extends BaseCompWrapperState<T> with UiServiceMixin {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// If anything has a focus, the set value event must be added as a listener.
  /// As to send it last.
  FocusNode? currentObjectFocused;

  /// The old cell editor which might have to be disposed of.
  ICellEditor? oldCellEditor;

  /// The currently used cell editor.
  ICellEditor cellEditor = FlDummyCellEditor();

  /// The value to send to the server on sendValue.
  dynamic _toSendValue;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void initState() {
    // Exception where we have to do stuff before we init the sate.
    // The layout information about the widget this editor has, eg custom min size is not yet in the editor model.
    recreateCellEditor(widget.model as T, false);

    (widget.model as FlEditorModel).applyComponentInformation(cellEditor.createWidgetModel());

    super.initState();

    subscribe(widget.model as T);
  }

  @override
  receiveNewModel({required T newModel}) {
    // If a change of cell editors has occured.
    if (newModel.changedCellEditor) {
      unsubscribe();

      recreateCellEditor(newModel);

      logCellEditor("RECEIVE_NEW_MODEL");

      newModel.applyComponentInformation(cellEditor.createWidgetModel());
    }

    super.receiveNewModel(newModel: newModel);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    // Celleditors always return a fresh new widget.
    // We must apply the universal editor components onto the widget.
    FlStatelessWidget editorWidget = cellEditor.createWidget();
    editorWidget.model.applyFromJson(model.json);
    // Some parts of a json have to take priority.
    // As they override the properties.
    editorWidget.model.applyCellEditorOverrides(model.json);

    logCellEditor("BUILD");

    return getPositioned(child: editorWidget);
  }

  @override
  void postFrameCallback(BuildContext context) {
    super.postFrameCallback(context);

    // Dispose of the old one after the build to clean up memory.
    oldCellEditor?.dispose();
    oldCellEditor = null;
  }

  @override
  void dispose() {
    cellEditor.dispose();
    super.dispose();
  }

  @override
  void sendCalcSize({required LayoutData pLayoutData, required String pReason}) {
    Size? newCalcSize;
    if (cellEditor is FlChoiceCellEditor) {
      FlChoiceCellEditor imageCellEditor = cellEditor as FlChoiceCellEditor;

      newCalcSize = imageCellEditor.imageSize;
    } else if (cellEditor is FlImageCellEditor) {
      FlImageCellEditor imageCellEditor = cellEditor as FlImageCellEditor;

      newCalcSize = imageCellEditor.imageSize;
    } else if (pLayoutData.hasCalculatedSize) {
      if (cellEditor is FlTextCellEditor ||
          cellEditor is FlLinkedCellEditor ||
          cellEditor is FlDateCellEditor ||
          cellEditor is FlNumberCellEditor) {
        double extraWidth = (cellEditor.createWidget() as FlTextFieldWidget).extraWidthPaddings();

        double averageColumnWidth = ParseUtil.getTextWidth(text: "w", style: model.getTextStyle());

        newCalcSize = Size(
          (averageColumnWidth * (cellEditor.createWidgetModel() as FlTextFieldModel).columns) + extraWidth,
          layoutData.calculatedSize!.height,
        );
      }
    }

    if (newCalcSize != null) {
      pLayoutData = pLayoutData.clone();
      pLayoutData.calculatedSize = newCalcSize;

      pLayoutData.widthConstrains.forEach((key, value) {
        pLayoutData.widthConstrains[key] = newCalcSize!.height;
      });
      pLayoutData.heightConstrains.forEach((key, value) {
        pLayoutData.heightConstrains[key] = newCalcSize!.width;
      });
    }

    super.sendCalcSize(pLayoutData: pLayoutData, pReason: pReason);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Method definitions
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Subscribes to the service and registers the set value call back.
  void subscribe(T pModel) {
    getUiService().registerDataSubscription(
      pDataSubscription: DataSubscription(
        subbedObj: this,
        dataProvider: pModel.dataProvider,
        from: -1,
        onSelectedRecord: setValue,
        onMetaData: setColumnDefinition,
        dataColumns: [pModel.columnName],
      ),
    );
  }

  /// Unsubscribes the callback of the cell editor from value changes.
  void unsubscribe() {
    getUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  /// Sets the state after value change to rebuild the widget and reflect the value change.
  void onChange(dynamic pValue) {
    setState(() {});
  }

  void setValue(DataRecord? pDataRecord) {
    if (pDataRecord != null) {
      cellEditor
          .setValue(pDataRecord.values[pDataRecord.columnDefinitions.indexWhere((e) => e.name == model.columnName)]);
    } else {
      cellEditor.setValue(null);
    }
    setState(() {});
  }

  void setColumnDefinition(DalMetaDataResponse pMetaData) {
    cellEditor.setColumnDefinition(pMetaData.columns.firstWhereOrNull((element) => element.name == model.columnName));
  }

  /// Sets the state of the widget and sends a set value command.
  void onEndEditing(dynamic pValue) {
    _toSendValue = pValue;
    setState(() {});

    if (cellEditor.isActionCellEditor()) {
      currentObjectFocused = FocusManager.instance.primaryFocus;
      if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
        currentObjectFocused = null;
        sendValue();
      } else {
        LOGGER.logI(pType: LogType.UI, pMessage: "Value will be set");
        currentObjectFocused!.addListener(sendValue);
        currentObjectFocused!.unfocus();
      }
    } else {
      sendValue();
    }
  }

  void recalculateSize([bool pRecalulcate = true]) {
    if (pRecalulcate) {
      sentCalcSize = false;
    }

    setState(() {});
  }

  void sendValue() {
    if (_toSendValue is HashMap<String, dynamic>) {
      var map = _toSendValue as HashMap<String, dynamic>;

      LOGGER.logI(pType: LogType.DATA, pMessage: "Values of ${model.id} set to $_toSendValue");
      getUiService().sendCommand(SetValuesCommand(
          componentId: model.id,
          dataProvider: model.dataProvider,
          columnNames: map.keys.toList(),
          values: map.values.toList(),
          reason: "Value of ${model.id} set to $_toSendValue"));
    } else {
      LOGGER.logI(pType: LogType.DATA, pMessage: "Value of ${model.id} set to $_toSendValue");
      getUiService().sendCommand(SetValuesCommand(
          componentId: model.id,
          dataProvider: model.dataProvider,
          columnNames: [model.columnName],
          values: [_toSendValue],
          reason: "Value of ${model.id} set to $_toSendValue"));
    }

    if (currentObjectFocused != null) {
      currentObjectFocused!.removeListener(sendValue);
    }
  }

  /// Recreates the cell editor.
  void recreateCellEditor(T pModel, [bool pSubscribe = true]) {
    oldCellEditor = cellEditor;

    var jsonCellEditor = Map<String, dynamic>.from(pModel.json[ApiObjectProperty.cellEditor]);
    cellEditor = ICellEditor.getCellEditor(
        pName: pModel.name,
        pCellEditorJson: jsonCellEditor,
        onChange: onChange,
        onEndEditing: onEndEditing,
        pRecalculateSizeCallback: recalculateSize,
        pUiService: getUiService());

    if (pSubscribe) {
      subscribe(pModel);
    }
  }

  /// Logs the cell editor for debug purposes.
  void logCellEditor(String pPhase) {
    LOGGER.logD(pType: LogType.UI, pMessage: StackTrace.current.toString());
    LOGGER.logD(pType: LogType.UI, pMessage: "----- $pPhase -----");
    LOGGER.logD(pType: LogType.UI, pMessage: "Old cell editor hashcode: ${oldCellEditor?.hashCode}");
    LOGGER.logD(pType: LogType.UI, pMessage: "New cell editor hashcode: ${cellEditor.hashCode}");
    LOGGER.logD(pType: LogType.UI, pMessage: "----- $pPhase -----");
  }
}
