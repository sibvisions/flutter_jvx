import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/widgets/custom/custom_icon.dart';
import 'package:flutterclient/src/util/icon/font_awesome_changer.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../models/api/response_objects/response_data/editor/cell_editor.dart';
import '../../../../models/api/response_objects/response_data/editor/cell_editor_properties.dart';
import '../../../../util/image/image_loader.dart';
import 'cell_editor_model.dart';

class ChoiceCellEditorModel extends CellEditorModel {
  List<ChoiceCellEditorImage> items = <ChoiceCellEditorImage>[];

  String? defaultImageName;

  late ChoiceCellEditorImage defaultImage;

  late ChoiceCellEditorImage selectedImage;

  List<String> allowedValues = <String>[];

  List<String> imageNames = <String>[];

  Size? tableMinimumSize = Size(50, 40);

  ChoiceCellEditorModel({required CellEditor cellEditor})
      : super(cellEditor: cellEditor) {
    defaultImageName = this.cellEditor.getProperty<String>(
        CellEditorProperty.DEFAULT_IMAGE_NAME, defaultImageName);
    if (defaultImageName == null) {
      defaultImageName = this.cellEditor.getProperty<String>(
          CellEditorProperty.DEFAULT_IMAGE, defaultImageName);
    }
    allowedValues = cellEditor.getProperty<List<String>>(
        CellEditorProperty.ALLOWED_VALUES, allowedValues)!;
    imageNames = cellEditor.getProperty<List<String>>(
        CellEditorProperty.IMAGE_NAMES, imageNames)!;
    if (imageNames.isEmpty) {
      imageNames = cellEditor.getProperty<List<String>>(
          CellEditorProperty.IMAGES, imageNames)!;
    }

    defaultImage = loadImage(defaultImageName);
    loadImages();
  }

  void loadImages() {
    this.imageNames.forEach((image) => this.items.add(loadImage(image)));

    this.selectedImage = this.items[1];
  }

  ChoiceCellEditorImage loadImage(String? path) {
    if (path != null && imageNames.isNotEmpty && allowedValues.isNotEmpty) {
      int indx = imageNames.indexOf(path);

      Size size = isPreferredSizeSet ? preferredSize! : Size(16, 16);

      if (isTableView) {
        size = isTablePreferredSizeSet ? tablePreferredSize! : Size(16, 16);
      }

      ChoiceCellEditorImage image = ChoiceCellEditorImage(
          image: CustomIcon(
            image: path,
            prefferedSize: size,
          ),
          value: allowedValues[indx]);

      return image;
    }

    return ChoiceCellEditorImage(image: null, value: '');
  }
}

class ChoiceCellEditorImage {
  String value;
  dynamic image;

  ChoiceCellEditorImage({required this.value, required this.image});
}
