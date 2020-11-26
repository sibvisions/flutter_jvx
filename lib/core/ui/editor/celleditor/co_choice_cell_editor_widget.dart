import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/ui/editor/celleditor/models/choice_cell_editor_model.dart';

import '../../../models/api/editor/cell_editor.dart';
import '../../../models/api/editor/cell_editor_properties.dart';
import '../../../ui/layout/i_alignment_constants.dart';
import '../../../utils/image/image_loader.dart';
import 'co_cell_editor_widget.dart';

class CoChoiceCellEditorWidget extends CoCellEditorWidget {
  final ChoiceCellEditorModel cellEditorModel;
  CoChoiceCellEditorWidget(
      {Key key, CellEditor changedCellEditor, this.cellEditorModel})
      : super(
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoChoiceCellEditorWidgetState();
}

class CoChoiceCellEditorWidgetState
    extends CoCellEditorWidgetState<CoChoiceCellEditorWidget> {
  List<ChoiceCellEditorImage> _items = <ChoiceCellEditorImage>[];
  ChoiceCellEditorImage defaultImage;
  ChoiceCellEditorImage selectedImage;
  Size tableMinimumSize = Size(50, 40);

  void valueChanged(dynamic value) {
    this.value = value;
    this.onValueChanged(value);
  }

  void loadImages() {
    widget.cellEditorModel.imageNames
        .forEach((image) => _items.add(loadImage(image)));

    selectedImage = _items[1];
  }

  ChoiceCellEditorImage loadImage(String path) {
    Image image = ImageLoader().loadImage('$path');
    String val;
    try {} catch (e) {
      selectedImage = defaultImage;
    }

    if (path == null ||
        widget.cellEditorModel.imageNames.indexOf(path) >
            widget.cellEditorModel.allowedValues.length - 1) {
      return defaultImage;
    } else {
      val = widget.cellEditorModel
          .allowedValues[widget.cellEditorModel.imageNames.indexOf(path)];
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

    defaultImage = loadImage(widget.cellEditorModel.defaultImageName);
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
        selectedImage =
            _items[widget.cellEditorModel.allowedValues.indexOf(this.value)];
      } else if (defaultImage != null) {
        selectedImage = defaultImage;
      }
    }

    return Container(
        child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                widget.cellEditorModel.horizontalAlignment),
            children: <Widget>[
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
            child: FlatButton(
              onPressed: () => widget.cellEditorModel.editable
                  ? setState(() => changeImage())
                  : null,
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
