import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui/layout/i_alignment_constants.dart';

import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import 'cell_editor_model.dart';
import 'co_cell_editor_widget.dart';
import 'package:jvx_flutterclient/utils/globals.dart' as globals;

class CoImageCellEditorWidget extends CoCellEditorWidget {
  CoImageCellEditorWidget({
    CellEditor changedCellEditor,
    CellEditorModel cellEditorModel,
    Key key,
  }) : super(
            key: key,
            changedCellEditor: changedCellEditor,
            cellEditorModel: cellEditorModel);

  @override
  State<StatefulWidget> createState() => CoImageCellEditorWidgetState();
}

class CoImageCellEditorWidgetState
    extends CoCellEditorWidgetState<CoImageCellEditorWidget> {
  String defaultImageName;
  Image defaultImage;
  Image currentImage;
  File file;
  double width = 100;
  double height = 100;
  BoxFit fit = BoxFit.scaleDown;
  Alignment alignment = Alignment.center;

  @override
  Size get preferredSize => Size(150, 150);

  @override
  Size get minimumSize => Size(50, 50);

  @override
  void initState() {
    super.initState();

    defaultImageName = widget.changedCellEditor
        .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME);

    if (defaultImageName != null) {
      if (kIsWeb && globals.files.containsKey(defaultImageName)) {
        setState(() {
          defaultImage =
              Image.memory(base64Decode(globals.files[defaultImageName]));
        });
      } else {
        file = File('${globals.dir}$defaultImageName');

        if (file.existsSync()) {
          setState(() {
            defaultImage = Image.file(file);
          });
        }
      }
    }
  }

  @override
  set value(_value) {
    if (_value != super.value) {
      super.value = _value;
      if (_value != null && _value.toString().isNotEmpty) {
        defaultImage = null;

        setState(() {
          currentImage = Image.memory(base64Decode(_value));
        });
      } else if (_value == null &&
          defaultImageName != null &&
          defaultImage == null) {
        currentImage = null;

        if (kIsWeb && globals.files.containsKey(defaultImageName)) {
          setState(() {
            defaultImage =
                (Image.memory(base64Decode(globals.files[defaultImageName])));
          });
        } else {
          if (file == null) {
            file = File(defaultImageName != null
                ? '${globals.dir}$defaultImageName'
                : 'assets/images/sib_visions.jpg');

            if (file.existsSync()) {
              setState(() {
                defaultImage = Image.file(file);
              });
            }
          } else {
            setState(() {
              defaultImage = Image.file(file);
            });
          }
        }
      }
    }
  }

  DecorationImage _getImage(double height, int horizontalAlignment) {
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

  @override
  Widget build(BuildContext context) {
    setEditorProperties(context);

    return ValueListenableBuilder(
      valueListenable: widget.cellEditorModel,
      builder: (context, value, child) {
        return LayoutBuilder(
          builder: (context, constraints) {
            double height = constraints.maxHeight != double.infinity
                ? constraints.maxHeight
                : null;
            double width = constraints.maxWidth != double.infinity
                ? constraints.maxWidth
                : null;

            return Container(
              child: Row(
                mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                    this.horizontalAlignment),
                children: [
                  Card(
                    color: Colors.white.withOpacity(
                        globals.applicationStyle?.controlsOpacity ?? 1.0),
                    elevation: 2.0,
                    shape: globals.applicationStyle?.editorsShape ??
                        RoundedRectangleBorder(),
                    child: Container(
                      height: height,
                      width: width - 10,
                      decoration: BoxDecoration(
                          image: _getImage(height, horizontalAlignment),
                          color: background != null
                              ? background
                              : Colors.transparent),
                    ),
                  )
                ],
              ),
            );
          },
        );
      },
    );
  }
}
