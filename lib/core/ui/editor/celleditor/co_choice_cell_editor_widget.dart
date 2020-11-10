import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../ui/layout/i_alignment_constants.dart';
import '../../../utils/image/image_loader.dart';
import 'cell_editor_model.dart';
import 'co_cell_editor_widget.dart';

class CoChoiceCellEditorWidget extends CoCellEditorWidget {
  CoChoiceCellEditorWidget(
      {Key key, CellEditor changedCellEditor, CellEditorModel cellEditorModel})
      : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoChoiceCellEditorWidgetState();
}

class CoChoiceCellEditorWidgetState
    extends CoCellEditorWidgetState<CoChoiceCellEditorWidget> {
  List<ChoiceCellEditorImage> _items = <ChoiceCellEditorImage>[];
  String defaultImageName;
  ChoiceCellEditorImage defaultImage;
  List<String> allowedValues;
  List<String> imageNames;
  ChoiceCellEditorImage selectedImage;
  Size tableMinimumSize = Size(50, 40);

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  void loadImages() {
    imageNames.forEach((image) => _items.add(loadImage(image)));

    selectedImage = _items[1];
  }

  ChoiceCellEditorImage loadImage(String path) {
    Image image = ImageLoader().loadImage('$path');
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
    onValueChanged(selectedImage.value, indexInTable);
  }

  @override
  void initState() {
    super.initState();
    defaultImageName = widget.changedCellEditor.getProperty<String>(
        CellEditorProperty.DEFAULT_IMAGE_NAME, defaultImageName);
    if (defaultImageName == null) {
      defaultImageName = widget.changedCellEditor
          .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE);
    }
    allowedValues = widget.changedCellEditor.getProperty<List<String>>(
        CellEditorProperty.ALLOWED_VALUES, allowedValues);
    imageNames = widget.changedCellEditor
        .getProperty<List<String>>(CellEditorProperty.IMAGE_NAMES, imageNames);
    if (imageNames == null || imageNames.length < 1) {
      imageNames = widget.changedCellEditor
          .getProperty<List<String>>(CellEditorProperty.IMAGES);
    }

    defaultImage = loadImage(defaultImageName);
    loadImages();
  }

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);

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
              onPressed: () =>
                  this.editable ? setState(() => changeImage()) : null,
              padding: EdgeInsets.all(0.0),
              child: selectedImage.image,
            ),
          )
        ]));
  }
}

class ChoiceCellEditorImage {
  String value;
  Image image;

  ChoiceCellEditorImage({this.value, this.image});
}
