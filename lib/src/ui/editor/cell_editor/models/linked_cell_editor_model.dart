import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';

import '../../../../models/api/response_objects/response_data/editor/cell_editor.dart';
import '../../../../util/app/text_utils.dart';
import 'referenced_cell_editor_model.dart';

class LinkedCellEditorModel extends ReferencedCellEditorModel {
  int pageIndex = 0;
  int pageSize = 100;

  @override
  set data(SoComponentData? data) {
    super.data = data;
  }

  LinkedCellEditorModel({required CellEditor cellEditor})
      : super(cellEditor: cellEditor);

  @override
  get preferredSize {
    String? text = "";

    // if ((referencedData?.data?.records != null) &&
    //     referencedData!.data!.records.length > 0) {
    //   List<String?> items = this.getItems();
    //   for (int i = 0; i < items.length && i < 10; i++) {
    //     if (text == null ||
    //         (items[i] != null && items[i]!.length > text.length)) {
    //       text = items[i];
    //     }
    //   }
    // }

    if (text == "") text = TextUtils.averageCharactersTextField;

    double width = TextUtils.getTextWidth(text, fontStyle).toDouble();

    return Size(width + 100, 50);
  }

  @override
  get minimumSize {
    return preferredSize;
  }

  @override
  Size get tableMinimumSize => Size(150, 50);
}
