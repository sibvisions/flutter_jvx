import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/column_view.dart';
import '../../../models/api/editor/link_reference.dart';
import '../../editor/celleditor/cell_editor_model.dart';
import '../../screen/so_component_data.dart';

class ReferencedCellEditorModel extends CellEditorModel {
  SoComponentData referencedData;
  LinkReference linkReference;
  ColumnView columnView;

  ReferencedCellEditorModel(CellEditor currentCellEditor)
      : super(currentCellEditor) {
    linkReference = currentCellEditor.linkReference;
    columnView = currentCellEditor.columnView;
    if (linkReference?.dataProvider == null)
      linkReference?.dataProvider = linkReference?.referencedDataBook;
    if (dataProvider == null) dataProvider = linkReference?.dataProvider;
  }
}
