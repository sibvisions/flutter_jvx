import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxImageCellEditor extends JVxCellEditor {
  String defaultImageName;
  Image defaultImage;

  JVxImageCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    defaultImageName = changedCellEditor
        .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME);
    if (defaultImageName != null) {
      File file = File(defaultImageName != null
          ? '${globals.dir}$defaultImageName'
          : 'assets/images/sib_visions.jpg');
      if (file.existsSync()) defaultImage = Image.file(file);
    }
  }

  @override
  Widget getWidget() {
    Image image = defaultImage;

    if (this.value!=null) {
      Uint8List bytes = base64Decode(this.value);
      image = Image.memory(bytes);
    }

    // ToDo: Implement getWidget
    if (image != null) {
      return image;
    }
  }
}
