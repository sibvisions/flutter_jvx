import 'dart:io';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/choice_cell_editor_image.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxChoiceCellEditor extends JVxCellEditor {
  List<ChoiceCellEditorImage> _items = <ChoiceCellEditorImage>[];
  String defaultImageName;
  ChoiceCellEditorImage defaultImage;
  List<String> allowedVales;
  List<String> imageNames;
  ChoiceCellEditorImage selectedImage;

  JVxChoiceCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    defaultImageName =
        changedCellEditor.getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME, defaultImageName);
    allowedVales =
        changedCellEditor.getProperty<List<String>>(CellEditorProperty.ALLOWED_VALUES, allowedVales);
    imageNames = changedCellEditor.getProperty<List<String>>(CellEditorProperty.IMAGE_NAMES, imageNames);

    // defaultImage = loadImage(defaultImageName);
    loadImages();
  }

  void valueChanged(dynamic value) {
    this.value = value;
    getIt
        .get<JVxScreen>()
        .setValues(dataProvider, columnView.columnNames, [value]);
  }

  void loadImages() {
    imageNames.forEach((image) => _items.add(loadImage(image)));

    selectedImage = _items[1];
  }

  ChoiceCellEditorImage loadImage(String path) {
    Image image = Image.file(File('${globals.dir}$path'));
    try {
    } catch (e) {
      selectedImage = defaultImage;
    }
    String val = allowedVales[imageNames.indexOf(path)];

    ChoiceCellEditorImage choiceCellEditorImage =
        ChoiceCellEditorImage(value: val, image: image);
    return choiceCellEditorImage;
  }

  changeImage() {
    if ((_items.indexOf(selectedImage) + 1) < _items.length)
      selectedImage = _items[_items.indexOf(selectedImage) + 1];
    else
      selectedImage = _items[0];

    getIt.get<JVxScreen>("screen").buttonCallback(null);
  }

  @override
  Widget getWidget() {
    return Container(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 40, maxHeight: 40),
        child: FlatButton(
          onPressed: () => changeImage(),
          padding: EdgeInsets.all(0.0),
          child: selectedImage.image,
        ),
      ),
    );
  }
}
