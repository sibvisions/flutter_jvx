import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:html' as html;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:convert' as utf8;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:jvx_flutterclient/jvx_flutterclient.dart';
import '../../layout/i_alignment_constants.dart';
import '../../../logic/bloc/api_bloc.dart';
import '../../../model/api/request/reload.dart';
import '../../../model/api/request/request.dart';
import '../../../model/cell_editor.dart';
import '../../../model/properties/cell_editor_properties.dart';
import 'co_cell_editor.dart';
import '../../../utils/globals.dart' as globals;

class CoImageCellEditor extends CoCellEditor {
  String defaultImageName;
  Image defaultImage;
  Image currentImage;
  File file;
  double width = 100;
  double heigth = 100;
  BoxFit fit = BoxFit.scaleDown;
  Alignment alignment = Alignment.center;
  //Size imageSize;

  @override
  get preferredSize {
    return Size(150, 150);
  }

  @override
  get minimumSize {
    return Size(50, 50);
  }

  CoImageCellEditor(CellEditor changedCellEditor, BuildContext context)
      : super(changedCellEditor, context) {
    defaultImageName = changedCellEditor
        .getProperty<String>(CellEditorProperty.DEFAULT_IMAGE_NAME);

    if (defaultImageName != null) {
      if (kIsWeb) {
        if (globals.files.containsKey(defaultImageName)) {
          defaultImage =
              Image.memory(utf8.base64Decode(globals.files[defaultImageName]));

          BlocProvider.of<ApiBloc>(context)
              .dispatch(Reload(requestType: RequestType.RELOAD));
        }
      } else {
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
  }

  factory CoImageCellEditor.withCompContext(ComponentContext componentContext) {
    return CoImageCellEditor(
        componentContext.cellEditor, componentContext.context);
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

      if (kIsWeb) {
        if (globals.files.containsKey(defaultImageName)) {
          defaultImage =
              Image.memory(utf8.base64Decode(globals.files[defaultImageName]));

          BlocProvider.of<ApiBloc>(context)
              .dispatch(Reload(requestType: RequestType.RELOAD));
        }
      } else {
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
  }

  DecorationImage getImage(double height, int horizontalAlignment) {
    if (horizontalAlignment == 3) {
      fit = BoxFit.fill;
    } else if (horizontalAlignment == 0) {
      alignment = Alignment.centerLeft;
    } else if (horizontalAlignment == 2) {
      alignment = Alignment.centerRight;
    }

    ImageProvider currImageProv;
    if (currentImage != null) {
      currImageProv = currentImage.image;
      /*_calculateImageDimension(currImageProv).then((size) {
        print("size = $size");
        imageSize = size;
      });*/
      return DecorationImage(
        //height: height,
        alignment: alignment,
        image: currImageProv,
        fit: fit,
      );
    } else if (defaultImage != null) {
      currImageProv = defaultImage.image;
      /*_calculateImageDimension(currImageProv).then((size) {
        print("size = $size");
        imageSize = size;
      });*/
      return DecorationImage(
        //height: height,
        alignment: alignment,
        image: currImageProv,
        fit: fit,
      );
    }

    return null;
  }

  Future<Size> _calculateImageDimension(ImageProvider provider) {
    Completer<Size> completer = Completer();
    provider.resolve(ImageConfiguration()).addListener(
      ImageStreamListener(
        (ImageInfo image, bool synchronousCall) {
          var myImage = image.image;
          Size size = Size(myImage.width.toDouble(), myImage.height.toDouble());
          completer.complete(size);
        },
      ),
    );
    return completer.future;
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

    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      double height = constraints.maxHeight != double.infinity
          ? constraints.maxHeight
          : null; //imageSize?.height;
      double width = constraints.maxWidth != double.infinity
          ? constraints.maxWidth
          : null; //imageSize?.width;

      return Container(
          child: Row(
              mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                  this.horizontalAlignment),
              children: <Widget>[
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
                      image: this.getImage(height, horizontalAlignment),
                      color:
                          background != null ? background : Colors.transparent
                      // : Colors.white.withOpacity(
                      //     globals.applicationStyle?.controlsOpacity ?? 1.0),
                      ),
                ))
          ]));
    });
  }
}
