import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/component/component_widget.dart';
import 'package:flutterclient/src/ui/editor/cell_editor/co_cell_editor_widget.dart';
import 'package:flutterclient/src/ui/editor/editor_component_model.dart';
import 'package:flutterclient/src/util/app/text_utils.dart';

class CoEditorWidget extends ComponentWidget {
  final CoCellEditorWidget cellEditor;

  CoEditorWidget(
      {Key? key,
      required this.cellEditor,
      required EditorComponentModel editorComponentModel})
      : super(componentModel: editorComponentModel, key: key) {
    editorComponentModel.cellEditor = cellEditor;
  }

  @override
  State<StatefulWidget> createState() => CoEditorWidgetState();

  static CoEditorWidgetState? of(BuildContext context) =>
      context.findAncestorStateOfType<CoEditorWidgetState>();
}

class CoEditorWidgetState extends ComponentWidgetState<CoEditorWidget> {
  void onBeginEditing() {}

  void onEndEditing() {}

  void onDataChanged() {}

  void onValueChanged(dynamic value, [int? index]) {}

  void onFilter(dynamic value) {}

  void onServerDataChanged() {}

  void _registerCallbacks() {
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

    _registerCallbacks();
  }

  @override
  Widget build(BuildContext context) {
    (widget.componentModel as EditorComponentModel)
        .setEditorProperties(context);

    CoCellEditorWidget? cellEditor =
        (widget.componentModel as EditorComponentModel).cellEditor;

    if (cellEditor == null) {
      return Container(
        margin: EdgeInsets.only(top: 9, bottom: 9),
        width: TextUtils.getTextWidth(
            TextUtils.averageCharactersTextField, TextStyle()),
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
            ? cellEditor.cellEditorModel.preferredSize!.height
            : null,
        width: cellEditor.cellEditorModel.preferredSize != null
            ? cellEditor.cellEditorModel.preferredSize!.width
            : null,
        child: cellEditor);
  }
}
