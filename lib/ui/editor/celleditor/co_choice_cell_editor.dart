import 'dart:io';
import 'package:flutter/material.dart';
import '../../../model/cell_editor.dart';
import '../../../model/choice_cell_editor_image.dart';
import '../../../model/properties/cell_editor_properties.dart';
import 'co_cell_editor.dart';
import '../../layout/i_alignment_constants.dart';
import '../../../utils/globals.dart' as globals;

class CoChoiceCellEditor extends CoCellEditor {
  List<ChoiceCellEditorImage> _items = <ChoiceCellEditorImage>[];
  String defaultImageName;
  ChoiceCellEditorImage defaultImage;
  List<String> allowedValues;
  List<String> imageNames;
  ChoiceCellEditorImage selectedImage;
  Size tableMinimumSize = Size(50, 40);

  CoChoiceCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    defaultImageName = changedCellEditor.getProperty<String>(
        CellEditorProperty.DEFAULT_IMAGE_NAME, defaultImageName);
    if (defaultImageName == null) {
      defaultImageName = changedCellEditor
          .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE);
    }
    allowedValues = changedCellEditor.getProperty<List<String>>(
        CellEditorProperty.ALLOWED_VALUES, allowedValues);
    imageNames = changedCellEditor.getProperty<List<String>>(
        CellEditorProperty.IMAGE_NAMES, imageNames);
    if (imageNames == null || imageNames.length < 1) {
      imageNames = changedCellEditor
          .getProperty<List<String>>(CellEditorProperty.IMAGES);
    }

    defaultImage = loadImage(defaultImageName);
    loadImages();
  }

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  void loadImages() {
    imageNames.forEach((image) => _items.add(loadImage(image)));

    selectedImage = _items[1];
  }

  ChoiceCellEditorImage loadImage(String path) {
    Image image = Image.file(File('${globals.dir}$path'));
    String val;
    try {} catch (e) {
      selectedImage = defaultImage;
    }

    if (path == null || imageNames.indexOf(path) > allowedValues.length - 1) {
      return defaultImage;
    } else {
      val = allowedValues[imageNames.indexOf(path)];
    }

    ChoiceCellEditorImage choiceCellEditorImage =
        ChoiceCellEditorImage(value: val, image: image);
    return choiceCellEditorImage;
  }

  changeImage() {
    if ((_items.indexOf(selectedImage) + 1) < _items.length)
      selectedImage = _items[_items.indexOf(selectedImage) + 1];
    else
      selectedImage = _items[0];

    this.value = selectedImage.value;
    onValueChanged(selectedImage.value);
  }

  @override
  Widget getWidget(
      {bool editable,
      Color background,
      Color foreground,
      String placeholder,
      String font,
      int horizontalAlignment}) {
    setEditorProperties(
        editable: editable,
        background: background,
        foreground: foreground,
        placeholder: placeholder,
        font: font,
        horizontalAlignment: horizontalAlignment);
    if (this.value is bool) {
      if (this.value)
        selectedImage = _items[0];
      else
        selectedImage = _items[1];
    } else {
      if (this.value != null && (this.value as String).isNotEmpty) {
        selectedImage = _items[this.allowedValues.indexOf(this.value)];
      } else if (defaultImage != null) {
        selectedImage = defaultImage;
      }
    }

    return Container(
        // decoration: BoxDecoration(
        //     color: background != null ? background : Colors.transparent,
        //     borderRadius: BorderRadius.circular(5),
        //     border:
        //         borderVisible ? Border.all(color: UIData.ui_kit_color_2) : null),
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                this.horizontalAlignment),
            children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
            child: FlatButton(
              onPressed: () => this.editable ? changeImage() : null,
              padding: EdgeInsets.all(0.0),
              child: selectedImage.image,
            ),
          )
        ]));
  }
}
