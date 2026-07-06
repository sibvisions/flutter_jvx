/*
 * Copyright 2022-2023 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

import '../../flutter_ui.dart';
import '../../service/config/i_config_service.dart';
import '../config_util.dart';
import '../jvx_colors.dart';

enum UploadType {
    FILE_SYSTEM,
    CAMERA,
    GALLERY,
}

abstract class FilePickerDialog {
    static Future<XFile?> openFilePicker() {
        BuildContext context = FlutterUI.getCurrentContext()!;

        if (kIsWeb) {
            return pick(UploadType.FILE_SYSTEM);
        }

        return showBarModalBottomSheet<XFile?>(
            context: context,
            backgroundColor: Theme.of(FlutterUI.getCurrentContext()!).dialogTheme.backgroundColor,
            barrierColor: JVxColors.LIGHTER_BLACK.withAlpha(Color.getAlphaFromOpacity(0.75)),
            clipBehavior: Clip.antiAliasWithSaveLayer,
            shape: const RoundedRectangleBorder(
                side: BorderSide.none,
                borderRadius: BorderRadius.only(topLeft: kDefaultBarTopRadius, topRight: kDefaultBarTopRadius),
            ),
            enableDrag: true,
            //otherwise the full height will be used - independent of the ContentBottomSheet
            expand: false,
            bounce: false,
            topControl: const SizedBox.shrink(),
            builder: (BuildContext context) {
                return SafeArea(
                    top: false,
                    child: SingleChildScrollView(
                        child: SizedBox(
                            height: 250,
                            child: Column(
                                children: [
                                    Container(
                                        padding: const EdgeInsets.only(top: 8, bottom: 4),
                                        child: Center(
                                            child: Container(
                                                width: 36,
                                                height: 5,
                                                decoration: BoxDecoration(
                                                    color: Colors.black.withAlpha(90),
                                                    borderRadius: BorderRadius.circular(2.5),
                                                ),
                                            ),
                                        ),
                                    ),
                                    Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                            Padding(
                                                padding: const EdgeInsets.only(top: 16, bottom: 12),
                                                child: Text(
                                                    FlutterUI.translate("Choose file"),
                                                    style: const TextStyle(fontSize: 20),
                                                ),
                                            ),
                                        ],
                                    ),
                                    InkWell(
                                        onTap: () => pick(UploadType.CAMERA).then((val) => {if (context.mounted) { Navigator.of(context).pop(val)}}),
                                        child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                    FaIcon(
                                                        FontAwesomeIcons.camera,
                                                        color: Theme.of(context).colorScheme.primary,
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
                                        onTap: () => pick(UploadType.GALLERY).then((val) => {if (context.mounted) { Navigator.of(context).pop(val)}} ),
                                        child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                    FaIcon(
                                                        FontAwesomeIcons.images,
                                                        color: Theme.of(context).colorScheme.primary,
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
                                        onTap: () => pick(UploadType.FILE_SYSTEM).then((val) => {if (context.mounted) { Navigator.of(context).pop(val)}}),
                                        child: Padding(
                                            padding: const EdgeInsets.all(16.0),
                                            child: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                    FaIcon(FontAwesomeIcons.folderOpen, color: Theme.of(context).colorScheme.primary),
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
                    )
                );
            });
    }

    static Future<XFile?> pick(UploadType type) async {
        Size? resolution = ConfigUtil.getPictureSize(IConfigService().pictureResolution.value);

        int? quality = IConfigService().pictureQuality.value;

        try {
            switch (type) {
                case UploadType.CAMERA:
                    ImagePicker picker = ImagePicker();

                    final pickedFile = await picker.pickImage(
                        source: ImageSource.camera,
                        maxWidth: resolution?.width,
                        maxHeight: resolution?.height,
                        imageQuality: quality,
                        requestFullMetadata: false,
                    );

                    return pickedFile;
                case UploadType.GALLERY:
                    ImagePicker picker = ImagePicker();

                    final pickedFile = await picker.pickImage(
                        source: ImageSource.gallery,
                        maxWidth: resolution?.width,
                        maxHeight: resolution?.height,
                        imageQuality: quality,
                        requestFullMetadata: false,
                    );

                    return pickedFile;
                case UploadType.FILE_SYSTEM:
                    FilePickerResult? result = await FilePicker.platform.pickFiles();

                    XFile? pickedFile = result?.xFiles.single;
                    if (pickedFile != null) {
                        return pickedFile;
                    }
            }
        } catch (e, stack) {
            FlutterUI.logUI.e("Failed to pick file", error: e, stackTrace: stack);
        }
        return null;
    }
}
