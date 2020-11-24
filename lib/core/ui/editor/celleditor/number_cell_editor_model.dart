import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../utils/app/text_utils.dart';
import '../../editor/celleditor/cell_editor_model.dart';

class NumberCellEditorModel extends CellEditorModel {
  BuildContext context;
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.fromLTRB(12, 15, 12, 5);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);

  NumberCellEditorModel(this.context, CellEditor currentCellEditor)
      : super(currentCellEditor);

  @override
  get preferredSize {
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    String text = TextUtils.averageCharactersTextField;

    if (this.value != null) {
      text = this.value.toString();
    }

    double width =
        TextUtils.getTextWidth(text, Theme.of(context).textTheme.button)
            .toDouble();

    return Size(width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get minimumSize {
    //if (super.isMinimumSizeSet) return super.minimumSize;
    double iconWidth = this.editable ? iconSize + iconPadding.horizontal : 0;
    return Size(10 + iconWidth + textPadding.horizontal, 100);
  }
}
