import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../utils/app/text_utils.dart';
import '../../editor/celleditor/cell_editor_model.dart';

class TextCellEditorModel extends CellEditorModel {
  String dateFormat;
  BuildContext context;
  bool multiLine = false;

  TextCellEditorModel(this.context, CellEditor currentCellEditor)
      : super(currentCellEditor);

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button)
        .toDouble();
    if (multiLine)
      return Size(width, 100);
    else
      return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(10, 50);
  }

  @override
  get tableMinimumSize {
    return this.preferredSize;
  }
}
