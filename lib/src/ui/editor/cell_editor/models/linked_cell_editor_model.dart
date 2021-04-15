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
    return _getPreferredSize();
  }

  @override
  get minimumSize {
    return preferredSize;
  }

  @override
  get tablePreferredSize {
    return _getPreferredSize(cellEditorValue);
  }

  @override
  Size get tableMinimumSize => Size(130, 50);

  Size _getPreferredSize([dynamic value]) {
    String? text = value;

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

    if (text == null || text == "") text = TextUtils.averageCharactersTextField;

    double width =
        TextUtils.getTextWidth(text, fontStyle, textScaleFactor).toDouble();

    return Size(width + 40, 50);
  }
}
