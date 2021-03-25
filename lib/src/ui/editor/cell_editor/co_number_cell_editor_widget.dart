import 'package:flutterclient/src/ui/editor/cell_editor/co_cell_editor_widget.dart';

import 'models/number_cell_editor_model.dart';

class CoNumberCellEditorWidget extends CoCellEditorWidget {
  final NumberCellEditorModel cellEditorModel;

  CoNumberCellEditorWidget({required this.cellEditorModel})
      : super(cellEditorModel: cellEditorModel);
}

class CoNumberCellEditorWidgetState
    extends CoCellEditorWidgetState<CoNumberCellEditorWidget> {}
