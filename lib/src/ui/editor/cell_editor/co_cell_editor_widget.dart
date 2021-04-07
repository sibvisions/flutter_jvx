import 'package:flutter/material.dart';

import 'models/cell_editor_model.dart';

class CoCellEditorWidget extends StatefulWidget {
  final CellEditorModel cellEditorModel;

  const CoCellEditorWidget({Key? key, required this.cellEditorModel})
      : super(key: key);

  @override
  CoCellEditorWidgetState createState() => CoCellEditorWidgetState();
}

class CoCellEditorWidgetState<T extends CoCellEditorWidget> extends State<T> {
  VoidCallback? onBeginEditing;
  VoidCallback? onEndEditing;
  Function(BuildContext context, dynamic value, [int index])? onValueChanged;
  ValueChanged<dynamic>? onFilter;

  getCallbacksFromModel() {
    this.onBeginEditing = widget.cellEditorModel.onBeginEditing;
    this.onEndEditing = widget.cellEditorModel.onEndEditing;
    this.onValueChanged = widget.cellEditorModel.onValueChanged;
    this.onFilter = widget.cellEditorModel.onFilter;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  onChange() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    getCallbacksFromModel();

    widget.cellEditorModel.addListener(onChange);
  }

  @override
  void dispose() {
    widget.cellEditorModel.removeListener(onChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Text('Cell editor not implemented yet!'),
    );
  }
}
