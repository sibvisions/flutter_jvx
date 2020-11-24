import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../utils/app/text_utils.dart';
import '../../editor/celleditor/cell_editor_model.dart';

class TextCellEditorModel extends CellEditorModel {
  String dateFormat;
  bool multiLine = false;
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.fromLTRB(12, 15, 12, 5);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);

  TextCellEditorModel(CellEditor currentCellEditor) : super(currentCellEditor);

  @override
  get preferredSize {
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    String text = TextUtils.averageCharactersTextField;

    if (!multiLine && this.value != null) {
      text = this.value;
    }

    double width = TextUtils.getTextWidth(text, fontStyle).toDouble();
    if (multiLine)
      return Size(width + iconWidth + textPadding.horizontal, 100);
    else
      return Size(width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    return Size(10 + iconWidth + textPadding.horizontal, 100);
  }

  @override
  get tableMinimumSize {
    return this.preferredSize;
  }
}
