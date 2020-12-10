import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../models/api/editor/cell_editor.dart';
import '../../../../models/api/editor/cell_editor_properties.dart';
import 'cell_editor_model.dart';

class ImageCellEditorModel extends CellEditorModel {
  String defaultImageName;
  Image defaultImage;
  Image currentImage;
  File file;
  double width = 100;
  double height = 100;
  BoxFit fit = BoxFit.contain;
  Alignment alignment = Alignment.center;

  @override
  Size get preferredSize => Size(150, 150);

  @override
  Size get minimumSize => Size(50, 50);

  @override
  set cellEditorValue(_value) {
    if (_value != super.cellEditorValue) {
      if (_value != null && _value.toString().isNotEmpty) {
        defaultImage = null;

        currentImage = Image.memory(base64Decode(_value));
      } else if (_value == null &&
          defaultImageName != null &&
          defaultImage == null) {
        currentImage = null;

        if (kIsWeb && this.appState.files.containsKey(defaultImageName)) {
          defaultImage = (Image.memory(
              base64Decode(this.appState.files[defaultImageName])));
        } else {
          if (file == null) {
            file = File(defaultImageName != null
                ? '${this.appState.dir}$defaultImageName'
                : appState.package
                    ? 'packages/jvx_flutterclient/assets/images/sib_visions.jpg'
                    : 'assets/images/sib_visions.jpg');

            if (file.existsSync()) {
              defaultImage = Image.file(file);
            }
          } else {
            defaultImage = Image.file(file);
          }
        }
      }

      if (_value == null) {
        currentImage = null;
      }

      super.cellEditorValue = _value;
    }
  }

  ImageCellEditorModel(CellEditor cellEditor) : super(cellEditor) {
    defaultImageName = this
        .cellEditor
        .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME);

    if (defaultImageName != null) {
      if (kIsWeb && this.appState.files.containsKey(defaultImageName)) {
        defaultImage =
            Image.memory(base64Decode(this.appState.files[defaultImageName]));
      } else {
        file = File('${this.appState.dir}$defaultImageName');

        if (file.existsSync()) {
          defaultImage = Image.file(file);
        }
      }
    }
  }

  DecorationImage getImage(double height, int horizontalAlignment) {
    switch (horizontalAlignment) {
      case 0:
        alignment = Alignment.centerLeft;
        break;
      case 1:
        break;
      case 2:
        alignment = Alignment.centerRight;
        break;
      case 3:
        fit = BoxFit.fill;
        break;
    }

    if (currentImage != null) {
      return DecorationImage(
          alignment: alignment, image: currentImage.image, fit: fit);
    } else if (defaultImage != null) {
      return DecorationImage(
          alignment: alignment, image: defaultImage.image, fit: fit);
    }

    return null;
  }
}
