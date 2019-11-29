import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/loading.dart';
import 'package:jvx_mobile_v3/model/api/request/reload.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/cell_editor.dart';
import 'package:jvx_mobile_v3/model/properties/cell_editor_properties.dart';
import 'package:jvx_mobile_v3/ui/editor/celleditor/jvx_cell_editor.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxImageCellEditor extends JVxCellEditor {
  String defaultImageName;
  Image defaultImage;
  Widget currentImage;
  File file;
  double width = 100;
  double heigth = 100;

  JVxImageCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    defaultImageName = changedCellEditor
        .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME);
    if (defaultImageName != null) {
      file = File(defaultImageName != null
          ? '${globals.dir}$defaultImageName'
          : 'assets/images/sib_visions.jpg');
      if (file.existsSync()) defaultImage = Image.file(file);
    }

    currentImage = Image.memory(file.readAsBytesSync());
    BlocProvider.of<ApiBloc>(context)
        .dispatch(Reload(requestType: RequestType.RELOAD));

    // Image img = new Image.file(file);
    // ImageProvider placeholder = FileImage(file);

    // if (this.value != null) {
    //   Uint8List bytes = base64Decode(this.value);
    //   img = Image.memory(bytes);
    //   placeholder = MemoryImage(bytes);
    // }

    // Completer<ui.Image> completer = new Completer<ui.Image>();
    // img.image
    //     .resolve(new ImageConfiguration())
    //     .addListener(ImageStreamListener((ImageInfo info, bool _) {
    //   completer.complete(info.image);
    // }));

    // currentImage = new FutureBuilder<ui.Image>(
    //   future: completer.future,
    //   builder: (BuildContext context, AsyncSnapshot<ui.Image> snapshot) {
    //     if (img.image is MemoryImage) {
    //       return Image(
    //         image: img.image,
    //         width: width,
    //         height: heigth,
    //       );
    //     }

    //     if (snapshot.hasData && this.value == null) {
    //       width = snapshot.data.width.toDouble();
    //       heigth = snapshot.data.height.toDouble();

    //       BlocProvider.of<ApiBloc>(context)
    //           .dispatch(Reload(requestType: RequestType.RELOAD));

    //       return Image(
    //         image: img.image,
    //         width: width,
    //         height: heigth,
    //       );
    //     }

    //     return Container(
    //       width: width,
    //       height: heigth,
    //       child: Center(
    //         child: CircularProgressIndicator(),
    //       ),
    //     );
    //   },
    // );

    // currentImage = img;
  }

  @override
  Widget getWidget() {
    if (this.value != null) {
      Uint8List bytes = base64Decode(this.value);
      currentImage = Image.memory(bytes);
      BlocProvider.of<ApiBloc>(context)
          .dispatch(Reload(requestType: RequestType.RELOAD));
    }

    return currentImage;
  }
}
