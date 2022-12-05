import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';

import '../flutter_ui.dart';
import '../service/config/i_config_service.dart';

enum UploadType {
  FILE_SYSTEM,
  CAMERA,
  GALLERY,
}

abstract class FilePickerDialog {
  static Future<XFile?> openFilePicker() {
    BuildContext context = FlutterUI.getCurrentContext()!;

    return showModalBottomSheet<XFile?>(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(10),
          ),
        ),
        context: context,
        builder: (BuildContext context) {
          return SingleChildScrollView(
            child: SizedBox(
              height: 230,
              width: double.infinity,
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 16),
                        child: Text(
                          FlutterUI.translate("Choose file"),
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
                    onTap: () => pick(UploadType.CAMERA).then((val) => Navigator.of(context).pop(val)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.camera,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            FlutterUI.translate("Camera"),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => pick(UploadType.GALLERY).then((val) => Navigator.of(context).pop(val)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FaIcon(
                            FontAwesomeIcons.images,
                            color: Theme.of(context).primaryColor,
                          ),
                          const SizedBox(width: 15),
                          Text(
                            FlutterUI.translate("Gallery"),
                            style: const TextStyle(fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () => pick(UploadType.FILE_SYSTEM).then((val) => Navigator.of(context).pop(val)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          FaIcon(FontAwesomeIcons.folderOpen, color: Theme.of(context).primaryColor),
                          const SizedBox(width: 15),
                          Text(
                            FlutterUI.translate("Filesystem"),
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
  }

  static Future<XFile?> pick(UploadType type) async {
    double? maxPictureWidth = IConfigService().getPictureResolution()?.toDouble();

    try {
      switch (type) {
        case UploadType.CAMERA:
          ImagePicker picker = ImagePicker();

          final pickedFile = await picker.pickImage(
            source: ImageSource.camera,
            maxWidth: maxPictureWidth,
            requestFullMetadata: false,
          );

          return pickedFile;
        case UploadType.GALLERY:
          ImagePicker picker = ImagePicker();

          final pickedFile = await picker.pickImage(
            source: ImageSource.gallery,
            requestFullMetadata: false,
          );

          return pickedFile;
        case UploadType.FILE_SYSTEM:
          FilePickerResult? result = await FilePicker.platform.pickFiles();

          // https://github.com/miguelpruivo/flutter_file_picker/issues/875
          PlatformFile? pickedFile = result?.files.single;
          if (pickedFile != null) {
            if (kIsWeb) {
              return XFile.fromData(
                pickedFile.bytes!,
                name: pickedFile.name,
              );
            }
            return XFile(
              pickedFile.path!,
              name: pickedFile.name,
            );
          }
      }
    } catch (e, stack) {
      FlutterUI.logUI.e("Failed to pick file", e, stack);
    }
    return null;
  }
}
