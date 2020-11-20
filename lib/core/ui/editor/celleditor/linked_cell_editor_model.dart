import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../utils/app/text_utils.dart';
import 'referenced_cell_editor_model.dart';

class LinkedCellEditorModel extends ReferencedCellEditorModel {
  int pageIndex = 0;
  int pageSize = 100;

  LinkedCellEditorModel(
      BuildContext screenContext, CellEditor currentCellEditor)
      : super(screenContext, currentCellEditor);

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

    if (text == "" || text.length < TextUtils.averageCharactersTextField.length)
      text = TextUtils.averageCharactersTextField;

    double width = TextUtils.getTextWidth(
            text, Theme.of(screenContext).textTheme.subtitle1)
        .toDouble();
    return Size(width + 100, 50);
  }

  @override
  get minimumSize {
    return Size(100, 50);
  }
}
