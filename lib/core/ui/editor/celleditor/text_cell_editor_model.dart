import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../utils/app/text_utils.dart';
import '../../editor/celleditor/cell_editor_model.dart';

class TextCellEditorModel extends CellEditorModel {
  String dateFormat;
  BuildContext context;
  bool multiLine = false;
  double iconSize = 24;

  TextCellEditorModel(this.context, CellEditor currentCellEditor)
      : super(currentCellEditor);

  @override
  get preferredSize {
    double iconWidth = this.editable ? iconSize : 0;
    String text = TextUtils.averageCharactersTextField;

    if (!multiLine &&
        this.value != null &&
        this.value.toString().length > text.length) {
      text = this.value;
    }

    double width =
        TextUtils.getTextWidth(text, Theme.of(context).textTheme.button)
            .toDouble();
    if (multiLine)
      return Size(width + iconWidth, 100);
    else
      return Size(width + iconWidth, 50);
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
