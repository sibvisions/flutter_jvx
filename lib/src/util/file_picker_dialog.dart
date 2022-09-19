import 'dart:developer';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:universal_io/io.dart';

import '../../flutter_jvx.dart';
import '../service/config/i_config_service.dart';
import '../service/service.dart';

enum UploadType {
  FILE_SYSTEM,
  CAMERA,
  GALLERY,
}

Future<File?> openFilePicker() async {
  BuildContext context = FlutterJVx.getCurrentContext()!;

  File? file;

  await showModalBottomSheet(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(10), topRight: Radius.circular(10))),
      context: context,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: SizedBox(
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
                        FlutterJVx.translate('Choose file'),
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    IconButton(
                      color: Colors.grey[300],
                      icon: const FaIcon(FontAwesomeIcons.circleXmark),
                      onPressed: () => Navigator.of(context).pop(),
                    )
                  ],
                ),
                InkWell(
                  onTap: () => pick(UploadType.CAMERA).then((val) async {
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
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          FlutterJVx.translate('Camera'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => pick(UploadType.GALLERY).then((val) {
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
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          FlutterJVx.translate('Gallery'),
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),
                ),
                InkWell(
                  onTap: () => pick(UploadType.FILE_SYSTEM).then((val) {
                    if (val != null) file = val;
                    Navigator.of(context).pop();
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        FaIcon(FontAwesomeIcons.folderOpen, color: Theme.of(context).primaryColor),
                        const SizedBox(
                          width: 15,
                        ),
                        Text(
                          FlutterJVx.translate('Filesystem'),
                          style: const TextStyle(fontSize: 18),
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

Future<File?> pick(UploadType type) async {
  double? maxPictureWidth = services<IConfigService>().getPictureResolution()?.toDouble();

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

        final pickedFile = await picker.pickImage(source: ImageSource.camera, maxWidth: maxPictureWidth);

        if (pickedFile != null) {
          file = File(pickedFile.path);
        }
        break;
      case UploadType.GALLERY:
        ImagePicker picker = ImagePicker();

        final pickedFile = await picker.pickImage(source: ImageSource.gallery);

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
