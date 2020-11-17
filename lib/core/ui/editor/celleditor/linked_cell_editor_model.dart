import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../utils/app/text_utils.dart';
import '../../editor/celleditor/cell_editor_model.dart';

class LinkedCellEditorModel extends CellEditorModel {
  BuildContext context;

  LinkedCellEditorModel(this.context, CellEditor currentCellEditor)
      : super(currentCellEditor);

  @override
  get preferredSize {
    double width = TextUtils.getTextWidth(TextUtils.averageCharactersTextField,
            Theme.of(context).textTheme.button)
        .toDouble();
    return Size(width, 50);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }
}
