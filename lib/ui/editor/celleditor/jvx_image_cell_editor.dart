import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/bloc/api_bloc.dart';
import '../../../model/api/request/reload.dart';
import '../../../model/api/request/request.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import '../../../ui/editor/celleditor/jvx_cell_editor.dart';
import '../../../utils/globals.dart' as globals;
import '../../../utils/uidata.dart';

class JVxImageCellEditor extends JVxCellEditor {
  String defaultImageName;
  Image defaultImage;
  Image currentImage;
  File file;
  double width = 100;
  double heigth = 100;
  BoxFit fit = BoxFit.scaleDown;
  Alignment alignment = Alignment.center;

  JVxImageCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    defaultImageName = changedCellEditor
        .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME);

    if (defaultImageName != null) {
      file = File(defaultImageName != null
          ? '${globals.dir}$defaultImageName'
          : 'assets/images/sib_visions.jpg');
      if (file.existsSync()) {
        defaultImage = Image.memory(
          file.readAsBytesSync(),
        );
        BlocProvider.of<ApiBloc>(context)
            .dispatch(Reload(requestType: RequestType.RELOAD));
      }
    }
  }

  @override
  set value(dynamic value) {
    super.value = value;
    if (value != null && value.toString().isNotEmpty) {
      defaultImage = null;
      Image img;
      if (file != null) {
        img = Image.file(
          file,
        );
      }
      Uint8List bytes = base64Decode(value);
      img = Image.memory(
        bytes,
      );

      Completer<ui.Image> completer = new Completer<ui.Image>();
      img.image
          .resolve(new ImageConfiguration())
          .addListener(ImageStreamListener((ImageInfo info, bool _) {
        completer.complete(info.image);
      }));

      completer.future.then((ui.Image snapshot) {
        if (snapshot != null) {
          currentImage = img;
          BlocProvider.of<ApiBloc>(context)
              .dispatch(Reload(requestType: RequestType.RELOAD));
        }
      });
    }
    if (value == null && defaultImageName != null && defaultImage == null) {
      currentImage = null;

      file = File(defaultImageName != null
          ? '${globals.dir}$defaultImageName'
          : 'assets/images/sib_visions.jpg');
      if (file.existsSync()) {
        defaultImage = Image.memory(
          file.readAsBytesSync(),
        );
        BlocProvider.of<ApiBloc>(context)
            .dispatch(Reload(requestType: RequestType.RELOAD));
      }
    }
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

    if (horizontalAlignment == 3) {
      fit = BoxFit.fill;
    } else if (horizontalAlignment == 0) {
      alignment = Alignment.centerLeft;
    } else if (horizontalAlignment == 2) {
      alignment = Alignment.centerRight;
    }

    ImageProvider currImageProv;
    Image showImg;
    if (currentImage != null) {
      currImageProv = currentImage.image;
      showImg = Image(
        alignment: alignment,
        image: currImageProv,
        fit: fit,
      );
    } else if (defaultImage != null) {
      currImageProv = defaultImage.image;
      showImg = Image(
        alignment: alignment,
        image: currImageProv,
        fit: fit,
      );
    }

    return Container(
      height: 200,
        decoration: BoxDecoration(
            color: background != null ? background : Colors.white.withOpacity(globals.applicationStyle.controlsOpacity),
            borderRadius: BorderRadius.circular(5),
            border: borderVisible
                ? Border.all(color: UIData.ui_kit_color_2)
                : null),
        child: showImg);
  }
}
