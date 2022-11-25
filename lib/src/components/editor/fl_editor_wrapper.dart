import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../../../components.dart';
import '../../../custom/app_manager.dart';
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

  const FlEditorWrapper({super.key, required super.id});

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
    if (_isDifferentValue(pValue)) {
      cellEditor.setValue(_currentValue);
      setState(() {});
      return;
    }

    IUiService()
        .saveAllEditors(
          pId: model.id,
          pFunction: () async {
            if (pValue is HashMap<String, dynamic>) {
              FlutterJVx.logUI.d("Values of ${model.id} set to $pValue");
              return [
                SetValuesCommand(
                  componentId: model.id,
                  dataProvider: model.dataProvider,
                  columnNames: pValue.keys.toList(),
                  values: pValue.values.toList(),
                  reason: "Value of ${model.id} set to $pValue",
                ),
              ];
            } else {
              FlutterJVx.logUI.d("Value of ${model.id} set to $pValue");
              return [
                SetValuesCommand(
                  componentId: model.id,
                  dataProvider: model.dataProvider,
                  columnNames: [model.columnName],
                  values: [pValue],
                  reason: "Value of ${model.id} set to $pValue",
                ),
              ];
            }
          },
          pReason: "Value of ${model.id} set to $pValue",
        )
        .catchError(IUiService().handleAsyncError);

    setState(() {});
  }

  void recalculateSize([bool pRecalulcate = true]) {
    if (pRecalulcate) {
      sentCalcSize = false;
    }

    setState(() {});
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
      onFocusChanged: _onFocusChange,
      pRecalculateSizeCallback: recalculateSize,
    );

    if (pSubscribe) {
      subscribe(pModel);
    }
  }

  /// Logs the cell editor for debug purposes.
  void logCellEditor(String pPhase) {
    FlutterJVx.logUI.d("""
----- $pPhase -----
Old cell editor hashcode: ${oldCellEditor?.hashCode}
New cell editor hashcode: ${cellEditor.hashCode}
----- $pPhase -----""", null, StackTrace.current);
  }

  @override
  BaseCommand? createSaveCommand() {
    dynamic value = cellEditor.getValue();
    //cellEditor.formatValue(pValue)
    if (_isDifferentValue(value)) {
      return null;
    }
    return SetValuesCommand(
      componentId: model.id,
      dataProvider: model.dataProvider,
      columnNames: [model.columnName],
      values: [value],
      reason: "Value of ${model.id} set to $value",
    );
  }

  bool _isDifferentValue(dynamic value) {
    return cellEditor.formatValue(value) == cellEditor.formatValue(_currentValue);
  }

  void _onFocusChange(bool pFocus) {
    if (pFocus) {
      sendFocusGainedCommand();
    } else {
      sendFocusLostCommand();
    }
  }
}
