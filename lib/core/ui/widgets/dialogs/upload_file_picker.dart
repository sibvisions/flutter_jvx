import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../../../models/app/app_state.dart';
import '../../../utils/translation/app_localizations.dart';

Future<File> openFilePicker(BuildContext context, AppState appState) async {
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
                        AppLocalizations.of(context).text('Choose file'),
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
                            targetWidth: appState.picSize ?? 320,
                            targetHeight: (properties.height ?? 400 *
                                    appState.picSize ?? 320 /
                                    properties.width ?? 400)
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
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          AppLocalizations.of(context).text('Camera'),
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
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          AppLocalizations.of(context).text('Gallery'),
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
                        FaIcon(FontAwesomeIcons.folderOpen,
                            color: Theme.of(context).primaryColor),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          AppLocalizations.of(context).text('Filesystem'),
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
                        AppLocalizations.of(context).text('Choose file'),
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
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(
                          width: 15,
                        ),
                        Text(
                          AppLocalizations.of(context).text('Filesystem'),
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
    PickedFile f = await ImagePicker().getImage(source: ImageSource.camera);

    file = File(f.path);
  } else if (type == 'gallery') {
    PickedFile f = await ImagePicker().getImage(source: ImageSource.gallery);

    file = File(f.path);
  } else if (type == 'file system') {
    // FilePickerResult result = await FilePicker.platform.pickFiles(type: FileType.any);

    // if (result.count > 0) {
    //   file = result.isSinglePick ? File(result.files[0].path) : null;
    // }
  }

  return file;
}
