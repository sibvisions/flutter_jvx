import 'package:flutter/material.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../utils/app/text_utils.dart';
import 'referenced_cell_editor_model.dart';

class LinkedCellEditorModel extends ReferencedCellEditorModel {
  int pageIndex = 0;
  int pageSize = 100;

  LinkedCellEditorModel(CellEditor currentCellEditor)
      : super(currentCellEditor);

  @override
  get preferredSize {
    String text = "";

    if ((this.referencedData?.data?.records != null ?? false) &&
        this.referencedData.data.records.length > 0) {
      List<String> items = this.getItems();
      for (int i = 0; i < items.length && i < 10; i++) {
        if (text == null ||
            (items[i] != null && items[i].length > text.length)) {
          text = items[i];
        }
      }
    }

    if (text == "") text = TextUtils.averageCharactersTextField;

    double width = TextUtils.getTextWidth(text, fontStyle).toDouble();

    // print("LinkedCellEditor PreferredSize: " +
    //     Size(width + 100, 50).toString() +
    //     "(" +
    //     text +
    //     ")");

    return Size(width + 100, 50);
  }

  @override
  get minimumSize {
    return preferredSize;
  }

  @override
  Size get tableMinimumSize => Size(150, 50);
}
