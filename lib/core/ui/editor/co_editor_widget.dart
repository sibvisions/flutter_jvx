import 'package:flutter/material.dart';

import '../../utils/app/text_utils.dart';
import '../component/component_widget.dart';
import 'celleditor/co_cell_editor_widget.dart';
import 'editor_component_model.dart';

class CoEditorWidget extends ComponentWidget {
  final CoCellEditorWidget cellEditor;

  CoEditorWidget({
    Key key,
    this.cellEditor,
    EditorComponentModel componentModel,
  }) : super(key: key, componentModel: componentModel);

  State<StatefulWidget> createState() => CoEditorWidgetState();

  static CoEditorWidgetState of(BuildContext context) =>
      context.findAncestorStateOfType<CoEditorWidgetState>();
}

class CoEditorWidgetState<T extends StatefulWidget>
    extends ComponentWidgetState<T> {
  void onBeginEditing() {}

  void onEndEditing() {}

  void onDataChanged() {
    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .onDataChanged(context);
  }

  void onValueChanged(dynamic value, [int index]) {
    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .onValueChanged(context, value, index);
  }

  void onFilter(dynamic value) {
    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .onFilter(value);
  }

  void onServerDataChanged() {
    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .onServerDataChanged(context);
  }

  @override
  void initState() {
    super.initState();
    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .cellEditor = (widget as CoEditorWidget).cellEditor;
  }

  @override
  Widget build(BuildContext context) {
    ((widget as CoEditorWidget).componentModel as EditorComponentModel)
        .setEditorProperties(context);

    CoCellEditorWidget cellEditor =
        ((widget as CoEditorWidget).componentModel as EditorComponentModel)
            .cellEditor;

    if (cellEditor == null) {
      return Container(
        margin: EdgeInsets.only(top: 9, bottom: 9),
        width: TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button),
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey)),
          child: TextField(
            readOnly: true,
            decoration: InputDecoration(
              contentPadding: EdgeInsets.all(12),
              border: InputBorder.none,
            ),
            style: TextStyle(color: Colors.grey[700]),
          ),
        ),
      );
    }

    return Container(
        height: cellEditor.cellEditorModel.preferredSize != null
            ? cellEditor.cellEditorModel.preferredSize.height
            : null,
        width: cellEditor.cellEditorModel.preferredSize != null
            ? cellEditor.cellEditorModel.preferredSize.width
            : null,
        child: cellEditor);
  }
}
