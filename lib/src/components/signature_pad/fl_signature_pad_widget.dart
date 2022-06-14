import 'dart:typed_data';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_client/main.dart';
import 'package:flutter_client/src/model/component/custom/fl_custom_container_model.dart';
import 'package:flutter_client/src/model/data/subscriptions/data_record.dart';
import 'package:flutter_client/util/image/image_loader.dart';
import 'package:flutter_client/util/logging/flutter_logger.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:signature/signature.dart';

import '../base_wrapper/fl_stateless_widget.dart';

class FlSignaturePadWidget<T extends FlCustomContainerModel> extends FlStatelessWidget<T> {
  final SignatureController controller;
  LongPressDownDetails? details;
  bool showImage = false;
  DataRecord? dataRecord;
  final Function sendSignature;
  final Function deleteSignature;

  FlSignaturePadWidget({
    Key? key,
    required T model,
    required this.controller,
    required this.sendSignature,
    required this.deleteSignature,
    required this.showImage,
    this.dataRecord,
  }) : super(
          key: key,
          model: model,
        );

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
                imageInBinary: true, imageInBase64: false, fit: BoxFit.scaleDown);
          }
        } catch (error, stacktrace) {
          LOGGER.logE(pType: LOG_TYPE.UI, pMessage: error.toString(), pStacktrace: stacktrace);
        }
      }

      image ??= ImageLoader.DEFAULT_IMAGE;

      return GestureDetector(
        onLongPress: () => showContextMenu(context),
        onLongPressDown: (details) => {this.details = details},
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: themeData.colorScheme.onPrimary),
            borderRadius: BorderRadius.circular(5),
          ),
          child: image,
        ),
      );
    }
    return GestureDetector(
      onLongPress: () => showContextMenu(context),
      onLongPressDown: (details) => {this.details = details},
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: themeData.colorScheme.onPrimary),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Signature(
          controller: controller,
          backgroundColor: model.background ?? themeData.backgroundColor,
        ),
      ),
    );
  }

  showContextMenu(BuildContext context) {
    if (details == null) {
      return;
    }

    List<PopupMenuEntry<SignatureContextMenuCommand>> popupMenuEntries =
        <PopupMenuEntry<SignatureContextMenuCommand>>[];

    if (dataRecord?.values[0] == null) {
      popupMenuEntries.add(_getContextMenuItem(FontAwesomeIcons.plusSquare, 'Done', SignatureContextMenuCommand.DONE));
      popupMenuEntries
          .add(_getContextMenuItem(FontAwesomeIcons.minusSquare, 'Clear', SignatureContextMenuCommand.CLEAR));
    } else {
      popupMenuEntries
          .add(_getContextMenuItem(FontAwesomeIcons.minusSquare, 'Clear', SignatureContextMenuCommand.CLEAR));
    }

    showMenu(
            position: RelativeRect.fromRect(
                details!.globalPosition & const Size(40, 40), Offset.zero & MediaQuery.of(context).size),
            context: context,
            items: popupMenuEntries)
        .then((val) {
      WidgetsBinding.instance!.focusManager.primaryFocus?.unfocus();
      if (val != null) {
        if (val == SignatureContextMenuCommand.DONE) {
          sendSignature();
        } else if (val == SignatureContextMenuCommand.CLEAR) {
          deleteSignature();
        }
      }
    });
  }

  PopupMenuItem<SignatureContextMenuCommand> _getContextMenuItem(
      IconData icon, String text, SignatureContextMenuCommand value) {
    return PopupMenuItem<SignatureContextMenuCommand>(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          FaIcon(
            icon,
            color: Colors.grey[600],
          ),
          Padding(padding: const EdgeInsets.only(left: 5), child: Text(text)),
        ],
      ),
      enabled: true,
      value: value,
    );
  }
}

enum SignatureContextMenuCommand { DONE, CLEAR }
