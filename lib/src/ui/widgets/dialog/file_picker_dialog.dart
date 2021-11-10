import 'dart:developer';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

enum UploadType {
  FILE_SYSTEM,
  CAMERA,
  GALLERY,
}

Future<File?> openFilePicker(BuildContext context, AppState appState) async {
  File? file;

  await showModalBottomSheet(
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            height: 230,
            width: double.infinity,
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(left: 16),
                      child: Text(
                        AppLocalizations.of(context)!.text('Choose file'),
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
                InkWell(
                  onTap: () =>
                      pick(appState, UploadType.CAMERA).then((val) async {
                    if (val != null) file = val;

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
                          AppLocalizations.of(context)!.text('Camera'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => pick(appState, UploadType.GALLERY).then((val) {
                    if (val != null) file = val;
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
                          AppLocalizations.of(context)!.text('Gallery'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () =>
                      pick(appState, UploadType.FILE_SYSTEM).then((val) {
                    if (val != null) file = val;
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
                          AppLocalizations.of(context)!.text('Filesystem'),
                          style: TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });

  return file;
}

Future<File?> pick(AppState appState, UploadType type) async {
  File? file;

  try {
    switch (type) {
      case UploadType.FILE_SYSTEM:
        FilePickerResult? result = await FilePicker.platform.pickFiles();

        if (result != null) {
          file = File(result.files.single.path!);
        }
        break;
      case UploadType.CAMERA:
        ImagePicker picker = ImagePicker();

        final pickedFile = await picker.getImage(
            source: ImageSource.camera, maxWidth: appState.picSize.toDouble());

        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
        break;
      case UploadType.GALLERY:
        ImagePicker picker = ImagePicker();

        final pickedFile = await picker.getImage(source: ImageSource.gallery);

        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
        break;
    }
  } on Exception catch (e) {
    log(e.toString());
  }

  return file;
}
