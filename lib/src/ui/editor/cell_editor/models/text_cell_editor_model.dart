import 'package:flutter/material.dart';

import '../../../../models/api/response_objects/response_data/editor/cell_editor.dart';
import '../../../../models/api/response_objects/response_data/editor/cell_editor_properties.dart';
import '../../../../util/app/text_utils.dart';
import 'cell_editor_model.dart';

class TextCellEditorModel extends CellEditorModel {
  String? dateFormat;
  bool multiLine = false;
  double iconSize = 24;
  EdgeInsets textPadding = EdgeInsets.only(left: 12);
  EdgeInsets iconPadding = EdgeInsets.only(right: 8);
  bool hasFocus = false;

  bool password = false;
  bool valueChanged = false;
  TextEditingController textController = TextEditingController();
  FocusNode focusNode = FocusNode();

  TextCellEditorModel({required CellEditor cellEditor})
      : super(cellEditor: cellEditor) {
    multiLine = cellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE, null)
            ?.contains('multiline') ??
        false;

    password = cellEditor
            .getProperty<String>(CellEditorProperty.CONTENT_TYPE, null)
            ?.contains('password') ??
        false;
  }

  @override
  set cellEditorValue(value) {
    textController.value = TextEditingValue(text: value ?? '');
    super.cellEditorValue = value;
  }

  @override
  get preferredSize {
    double iconWidth = editable ? iconSize + iconPadding.horizontal : 0;
    String text = TextUtils.averageCharactersTextField;

    if (!multiLine &&
        cellEditorValue != null &&
        cellEditorValue.toString().length > 0) {
      text = cellEditorValue;
    }

    double width =
        TextUtils.getTextWidth(text, fontStyle, textScaleFactor).toDouble();

    if (multiLine)
      return Size(18 + width + iconWidth + textPadding.horizontal, 100);
    else
      return Size(18 + width + iconWidth + textPadding.horizontal, 50);
  }

  @override
  get minimumSize {
    return preferredSize;
  }

  @override
  get tableMinimumSize {
    return preferredSize;
  }
}
