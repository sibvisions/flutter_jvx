import 'package:flutter/material.dart';
import '../component/component_widget.dart';
import 'cell_editor/co_cell_editor_widget.dart';
import 'editor_component_model.dart';
import '../../util/app/text_utils.dart';

class CoEditorWidget extends ComponentWidget {
  final CoCellEditorWidget? cellEditor;

  CoEditorWidget(
      {Key? key,
      this.cellEditor,
      required EditorComponentModel editorComponentModel})
      : super(componentModel: editorComponentModel, key: key) {
    editorComponentModel.cellEditor = cellEditor;
  }

  @override
  State<StatefulWidget> createState() => CoEditorWidgetState();

  static CoEditorWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<CoEditorWidgetState>();
}

class CoEditorWidgetState<T extends CoEditorWidget>
    extends ComponentWidgetState<T> {
  void onBeginEditing() {}

  void onEndEditing() {}

  void onDataChanged() {}

  void onValueChanged(dynamic value, [int? index]) {}

  void onFilter(dynamic value) {}

  void onServerDataChanged() {
    if (widget.cellEditor != null &&
        widget.cellEditor!.cellEditorModel.isTableView) setState(() {});
  }

  void registerCallbacks() {
    EditorComponentModel editorComponentModel =
        widget.componentModel as EditorComponentModel;

    editorComponentModel.onBeginEditingCallback = onBeginEditing;
    editorComponentModel.onEndEditingCallback = onEndEditing;
    editorComponentModel.onDataChangedCallback = onDataChanged;
    editorComponentModel.onValueChangedCallback = onValueChanged;
    editorComponentModel.onFilterCallback = onFilter;
    editorComponentModel.onServerDataChangedCallback = onServerDataChanged;
  }

  @override
  void initState() {
    super.initState();

    registerCallbacks();
  }

  @override
  Widget build(BuildContext context) {
    CoCellEditorWidget? cellEditor =
        (widget.componentModel as EditorComponentModel).cellEditor;

    if (cellEditor == null) {
      return Container(
        margin: EdgeInsets.only(top: 9, bottom: 9),
        width: TextUtils.getTextWidth(
            TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button ?? TextStyle(),
            MediaQuery.of(context).textScaleFactor),
        height: 50,
        child: DecoratedBox(
          decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: Colors.grey)),
          child: TextFormField(
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

    cellEditor.cellEditorModel.textScaleFactor =
        MediaQuery.of(context).textScaleFactor;
    return Container(
        height: cellEditor.cellEditorModel.preferredSize != null
            ? cellEditor.cellEditorModel.preferredSize!.height
            : null,
        width: cellEditor.cellEditorModel.preferredSize != null
            ? cellEditor.cellEditorModel.preferredSize!.width
            : null,
        child: cellEditor);
  }
}
