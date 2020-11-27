import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:jvx_flutterclient/core/ui/editor/co_editor_widget.dart';

import 'models/cell_editor_model.dart';

class CoCellEditorWidget extends StatefulWidget {
  final CellEditorModel cellEditorModel;

  const CoCellEditorWidget({
    Key key,
    this.cellEditorModel,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      CoCellEditorWidgetState<CoCellEditorWidget>();
}

class CoCellEditorWidgetState<T extends StatefulWidget> extends State<T> {
  VoidCallback onBeginEditing;
  VoidCallback onEndEditing;
  Function(BuildContext context, dynamic value, [int index]) onValueChanged;
  ValueChanged<dynamic> onFilter;

  getCallbacksFromModel() {
    this.onBeginEditing = (widget as CoCellEditorWidget).cellEditorModel.onBeginEditing;
    this.onEndEditing = (widget as CoCellEditorWidget).cellEditorModel.onEndEditing;
    this.onValueChanged = (widget as CoCellEditorWidget).cellEditorModel.onValueChanged;
    this.onFilter = (widget as CoCellEditorWidget).cellEditorModel.onFilter;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    this.getCallbacksFromModel();

    (widget as CoCellEditorWidget)
        .cellEditorModel
        .addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
