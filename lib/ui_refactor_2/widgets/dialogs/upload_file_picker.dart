import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../utils/globals.dart' as globals;
import '../../../utils/translations.dart';
import '../../../utils/uidata.dart';

Future<File> openFilePicker(BuildContext context) async {
  File file;
  if (!kIsWeb) {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 220,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        Translations.of(context)
                            .text2('Choose file', 'Choose file'),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      color: Colors.grey[300],
                      icon: FaIcon(FontAwesomeIcons.timesCircle),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => pick('camera').then((val) async {
                    ImageProperties properties =
                        await FlutterNativeImage.getImageProperties(val.path);
                    File compressedImage =
                        await FlutterNativeImage.compressImage(val.path,
                            quality: 80,
                            targetWidth: globals.uploadPicWidth,
                            targetHeight: (properties.height *
                                    globals.uploadPicWidth /
                                    properties.width)
                                .round());

                    file = compressedImage;

                    Navigator.of(context).pop();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FaIcon(
                          FontAwesomeIcons.camera,
                          color: UIData.ui_kit_color_2,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          Translations.of(context).text2('Camera', 'Camera'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => pick('gallery').then((val) {
                    file = val;
                    Navigator.of(context).pop();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FaIcon(
                          FontAwesomeIcons.images,
                          color: UIData.ui_kit_color_2,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          Translations.of(context).text2('Gallery', 'Gallery'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: () => pick('file system').then((val) {
                    file = val;
                    Navigator.of(context).pop();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FaIcon(
                          FontAwesomeIcons.folderOpen,
                          color: UIData.ui_kit_color_2,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          Translations.of(context).text2('Filesystem'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  } else {
    await showModalBottomSheet(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10), topRight: Radius.circular(10))),
        context: context,
        builder: (BuildContext context) {
          return Container(
            height: 120,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        Translations.of(context)
                            .text2('Choose file', 'Choose file'),
                        style: TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      color: Colors.grey[300],
                      icon: FaIcon(FontAwesomeIcons.timesCircle),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                GestureDetector(
                  onTap: () => pick('file system').then((val) {
                    file = val;
                    Navigator.of(context).pop();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FaIcon(
                          FontAwesomeIcons.folderOpen,
                          color: UIData.ui_kit_color_2,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          Translations.of(context).text2('Filesystem'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        });
  }

  return file;
}

Future<File> pick(String type) async {
  File file;

  if (type == 'camera') {
    file = await ImagePicker.pickImage(source: ImageSource.camera);
  } else if (type == 'gallery') {
    file = await ImagePicker.pickImage(source: ImageSource.gallery);
  } else if (type == 'file system') {
    file = await FilePicker.getFile(type: FileType.any);
  }

  return file;
}
