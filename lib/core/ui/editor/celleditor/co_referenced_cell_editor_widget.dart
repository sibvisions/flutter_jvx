import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/referenced_cell_editor_model.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/column_view.dart';
import '../../../models/api/editor/link_reference.dart';
import '../../screen/so_component_data.dart';
import 'cell_editor_model.dart';
import 'co_cell_editor_widget.dart';

class CoReferencedCellEditorWidget extends CoCellEditorWidget {
  final ReferencedCellEditorModel cellEditorModel;

  CoReferencedCellEditorWidget({
    CellEditor changedCellEditor,
    this.cellEditorModel,
  }) : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() =>
      CoReferencedCellEditorWidgetState<CoReferencedCellEditorWidget>();
}

class CoReferencedCellEditorWidgetState<T extends StatefulWidget>
    extends CoCellEditorWidgetState<T> {
  SoComponentData get referencedData =>
      (widget as CoReferencedCellEditorWidget).cellEditorModel.referencedData;
  set referencedData(SoComponentData data) {
    (widget as CoReferencedCellEditorWidget).cellEditorModel.referencedData =
        data;
    data?.unregisterDataChanged(onServerDataChanged);
    data?.registerDataChanged(onServerDataChanged);
  }

  void onServerDataChanged() {
    this.setState(() {});
  }

  @override
  void initState() {
    super.initState();
    CoReferencedCellEditorWidget referencedCellEditorWidget =
        (widget as CoReferencedCellEditorWidget);
    this.referencedData = referencedCellEditorWidget.cellEditorModel.data;

    referencedCellEditorWidget.cellEditorModel.linkReference =
        referencedCellEditorWidget.changedCellEditor.linkReference;
    referencedCellEditorWidget.cellEditorModel.columnView =
        referencedCellEditorWidget.changedCellEditor.columnView;
    if (referencedCellEditorWidget
            .cellEditorModel.linkReference?.dataProvider ==
        null)
      referencedCellEditorWidget.cellEditorModel.linkReference?.dataProvider =
          referencedCellEditorWidget
              .cellEditorModel.linkReference?.referencedDataBook;
    if (dataProvider == null)
      dataProvider = referencedCellEditorWidget
          .cellEditorModel.linkReference?.dataProvider;
  }
}
