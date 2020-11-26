import 'package:flutter/material.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import '../../../../utils/image/image_loader.dart';
import 'cell_editor_model.dart';

class ChoiceCellEditorModel extends CellEditorModel {
  List<ChoiceCellEditorImage> items = <ChoiceCellEditorImage>[];
  String defaultImageName;
  ChoiceCellEditorImage defaultImage;
  List<String> allowedValues;
  List<String> imageNames;
  ChoiceCellEditorImage selectedImage;
  Size tableMinimumSize = Size(50, 40);

  ChoiceCellEditorModel(CellEditor cellEditor) : super(cellEditor) {
    defaultImageName = this.cellEditor.getProperty<String>(
        CellEditorProperty.DEFAULT_IMAGE_NAME, defaultImageName);
    if (defaultImageName == null) {
      defaultImageName =
          this.cellEditor.getProperty<String>(CellEditorProperty.DEFAULT_IMAGE);
    }
    allowedValues = this.cellEditor.getProperty<List<String>>(
        CellEditorProperty.ALLOWED_VALUES, allowedValues);
    imageNames = this
        .cellEditor
        .getProperty<List<String>>(CellEditorProperty.IMAGE_NAMES, imageNames);
    if (imageNames == null || imageNames.length < 1) {
      imageNames =
          this.cellEditor.getProperty<List<String>>(CellEditorProperty.IMAGES);
    }

    defaultImage = loadImage(defaultImageName);
    loadImages();
  }

  void loadImages() {
    this.imageNames.forEach((image) => this.items.add(loadImage(image)));

    this.selectedImage = this.items[1];
  }

  ChoiceCellEditorImage loadImage(String path) {
    Image image = ImageLoader().loadImage('$path');
    String val;
    try {} catch (e) {
      this.selectedImage = this.defaultImage;
    }

    if (path == null ||
        this.imageNames.indexOf(path) > this.allowedValues.length - 1) {
      return this.defaultImage;
    } else {
      val = this.allowedValues[this.imageNames.indexOf(path)];
    }

    ChoiceCellEditorImage choiceCellEditorImage =
        ChoiceCellEditorImage(value: val, image: image);
    return choiceCellEditorImage;
  }
}

class ChoiceCellEditorImage {
  String value;
  Image image;

  ChoiceCellEditorImage({this.value, this.image});
}
