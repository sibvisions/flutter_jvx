import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/co_choice_cell_editor_widget.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import 'cell_editor_model.dart';

class ChoiceCellEditorModel extends CellEditorModel {
  List<ChoiceCellEditorImage> _items = <ChoiceCellEditorImage>[];
  String defaultImageName;
  ChoiceCellEditorImage defaultImage;
  List<String> allowedValues;
  List<String> imageNames;
  ChoiceCellEditorImage selectedImage;
  Size tableMinimumSize = Size(50, 40);

  ChoiceCellEditorModel(CellEditor currentCellEditor)
      : super(currentCellEditor) {
    defaultImageName = currentCellEditor.getProperty<String>(
        CellEditorProperty.DEFAULT_IMAGE_NAME, defaultImageName);
    if (defaultImageName == null) {
      defaultImageName = currentCellEditor
          .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE);
    }
    allowedValues = currentCellEditor.getProperty<List<String>>(
        CellEditorProperty.ALLOWED_VALUES, allowedValues);
    imageNames = currentCellEditor.getProperty<List<String>>(
        CellEditorProperty.IMAGE_NAMES, imageNames);
    if (imageNames == null || imageNames.length < 1) {
      imageNames = currentCellEditor
          .getProperty<List<String>>(CellEditorProperty.IMAGES);
    }
  }
}
