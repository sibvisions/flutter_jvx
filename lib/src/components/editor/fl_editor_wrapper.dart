import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../components.dart';
import '../../../data.dart';
import '../../../flutter_jvx.dart';
import '../../../services.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/component/editor/fl_editor_model.dart';
import '../../model/layout/layout_data.dart';
import '../../service/api/shared/api_object_property.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'cell_editor/fl_dummy_cell_editor.dart';
import 'cell_editor/i_cell_editor.dart';

/// The [FlEditorWrapper] wraps various cell editors and makes them usable as single wrapped widgets.
/// It serves as the layouting wrapper of various non layouting widgets.
class FlEditorWrapper<T extends FlEditorModel> extends BaseCompWrapperWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlEditorWrapper({Key? key, required String id}) : super(key: key, id: id);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlEditorWrapperState createState() => FlEditorWrapperState();
}

class FlEditorWrapperState<T extends FlEditorModel> extends BaseCompWrapperState<T> {
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

  /// Last value;
  dynamic _currentValue;

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
  receiveNewModel(T pModel) {
    // If a change of cell editors has occured.
    if (pModel.changedCellEditor) {
      unsubscribe();

      recreateCellEditor(pModel);

      logCellEditor("RECEIVE_NEW_MODEL");

      pModel.applyComponentInformation(cellEditor.createWidgetModel());
    }

    super.receiveNewModel(pModel);
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    logCellEditor("BUILD");

    return getPositioned(child: cellEditor.createWidget(model.json, false));
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

    double? width = cellEditor.getEditorSize(model.json, false);
    if (width != null) {
      width += cellEditor.getContentPadding(model.json, false);

      if (cellEditor is FlChoiceCellEditor || cellEditor is FlImageCellEditor) {
        newCalcSize = Size.square(width);
      } else {
        newCalcSize = Size(
          width,
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
    if (pModel.dataProvider.isNotEmpty) {
      IUiService().registerDataSubscription(
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
  }

  /// Unsubscribes the callback of the cell editor from value changes.
  void unsubscribe() {
    IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.dataProvider);
  }

  /// Sets the state after value change to rebuild the widget and reflect the value change.
  void onChange(dynamic pValue) {
    setState(() {});
  }

  void setValue(DataRecord? pDataRecord) {
    if (pDataRecord != null) {
      _currentValue = pDataRecord.values[pDataRecord.columnDefinitions.indexWhere((e) => e.name == model.columnName)];
    } else {
      _currentValue = null;
    }
    cellEditor.setValue(_currentValue);
    setState(() {});
  }

  void setColumnDefinition(DalMetaDataResponse pMetaData) {
    ColumnDefinition? newColDef = pMetaData.columns.firstWhereOrNull((element) => element.name == model.columnName);
    cellEditor.setColumnDefinition(newColDef);
    setState(() {});
  }

  /// Sets the state of the widget and sends a set value command.
  void onEndEditing(dynamic pValue) {
    if ((pValue?.toString() ?? "") == (_currentValue?.toString() ?? "")) {
      return;
    }

    _toSendValue = pValue;
    setState(() {});

    currentObjectFocused = FocusManager.instance.primaryFocus;
    if (currentObjectFocused == null || currentObjectFocused!.parent == null) {
      currentObjectFocused = null;
      sendValue();
    } else {
      FlutterJVx.log.i("Value will be set");
      currentObjectFocused!.addListener(sendValue);
      currentObjectFocused!.unfocus();
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

      FlutterJVx.log.i("Values of ${model.id} set to $_toSendValue");
      IUiService().sendCommand(SetValuesCommand(
          componentId: model.id,
          dataProvider: model.dataProvider,
          columnNames: map.keys.toList(),
          values: map.values.toList(),
          reason: "Value of ${model.id} set to $_toSendValue"));
    } else {
      FlutterJVx.log.i("Value of ${model.id} set to $_toSendValue");
      IUiService().sendCommand(SetValuesCommand(
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
    );

    if (pSubscribe) {
      subscribe(pModel);
    }
  }

  /// Logs the cell editor for debug purposes.
  void logCellEditor(String pPhase) {
    FlutterJVx.log.d("""
----- $pPhase -----
Old cell editor hashcode: ${oldCellEditor?.hashCode}
New cell editor hashcode: ${cellEditor.hashCode}
----- $pPhase -----""", null, StackTrace.current);
  }
}
