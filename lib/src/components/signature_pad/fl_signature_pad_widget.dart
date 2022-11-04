import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:signature/signature.dart';

import '../../../flutter_jvx.dart';
import '../../../util/image/image_loader.dart';
import '../../model/component/custom/fl_custom_container_model.dart';
import '../../model/data/subscriptions/data_record.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlSignaturePadWidget extends FlStatelessWidget<FlCustomContainerModel> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final SignatureController controller;
  final double? width;
  final double? height;
  final bool showImage;
  final DataRecord? dataRecord;
  final VoidCallback sendSignature;
  final VoidCallback deleteSignature;
  final VoidCallback? onLongPress;
  final Function(LongPressDownDetails?)? onLongPressDown;

  const FlSignaturePadWidget({
    Key? key,
    required FlCustomContainerModel model,
    required this.controller,
    required this.width,
    required this.height,
    required this.sendSignature,
    required this.deleteSignature,
    required this.showImage,
    this.dataRecord,
    this.onLongPress,
    this.onLongPressDown,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    if (showImage) {
      dynamic imageValue = dataRecord?.values[0];

      Widget? image;
      if (imageValue != null) {
        try {
          if (imageValue is String && imageValue.startsWith("[")) {
            List<String> listOfSnippets = imageValue.substring(1, imageValue.length - 1).split(",");

            imageValue = Uint8List.fromList(listOfSnippets.map((e) => int.parse(e)).toList());
          }

          if (imageValue is Uint8List) {
            image = ImageLoader.loadImage(String.fromCharCodes(imageValue),
                pImageInBinary: true, pImageInBase64: false, pFit: BoxFit.scaleDown);
          }
        } catch (error, stacktrace) {
          FlutterJVx.logUI.e("Failed to show image", error, stacktrace);
        }
      }

      image ??= ImageLoader.DEFAULT_IMAGE;

      return GestureDetector(
        onLongPress: () => onLongPress?.call(),
        onLongPressDown: (details) => onLongPressDown?.call(details),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Padding(
            padding: const EdgeInsets.all(3.0),
            child: image,
          ),
        ),
      );
    }
    return GestureDetector(
      onLongPress: () => onLongPress?.call(),
      onLongPressDown: (details) => onLongPressDown?.call(details),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Theme.of(context).colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Signature(
            key: UniqueKey(),
            //TODO Remove after initState fix for width and height
            width: width,
            height: height,
            controller: controller,
            backgroundColor: model.background ?? Theme.of(context).backgroundColor,
          ),
        ),
      ),
    );
  }
}

enum SignatureContextMenuCommand { DONE, CLEAR }
