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
  Function(dynamic value, [int index]) onValueChanged;
  ValueChanged<dynamic> onFilter;

  void getCallbacks() {
    CoEditorWidgetState editor = CoEditorWidget.of(context);

    this.onBeginEditing = editor.onBeginEditing;
    this.onEndEditing = editor.onEndEditing;
    this.onValueChanged = editor.onValueChanged;
    this.onFilter = editor.onFilter;
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

    SchedulerBinding.instance.addPostFrameCallback((_) => getCallbacks());

    (widget as CoCellEditorWidget)
        .cellEditorModel
        .addListener(() => setState(() {}));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
