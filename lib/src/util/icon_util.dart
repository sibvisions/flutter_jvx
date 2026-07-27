/*
 * Copyright 2024 SIB Visions GmbH
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

import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'dart:ui' as ui;
import 'font_awesome_util.dart';
import 'material_icons_util.dart';
import 'parse_util.dart';

enum IconType { Material, FontAwesome }

abstract class IconUtil {

    /// The default icon size.
    static const double DEFAULT_ICON_SIZE = 16;

    /// The font awesome icon name prefix
    static const String PREFIX_FONT_AWESOME = "FontAwesome.";

    /// The material icon name prefix
    static const String PREFIX_MATERIAL = "Material.";

    // Private constructor to prevent instantiation
    IconUtil._();

    static Map<String, String>? parseArguments(String? imageDefinition) {
        if (imageDefinition == null || imageDefinition.isEmpty) {
            return null;
        }

        // name;arg=value;arg2=value2,width,height,dynamic
        String? imageDefinition_ = imageDefinition;

        Map<String, String> arguments = {};

        List<String> fontDefElements = imageDefinition_.split(",");

        List<String> fontWithArguments = fontDefElements[0].split(";");

        for (int i = 1; i < fontWithArguments.length; i++) {
            List<String> arg = fontWithArguments[i].split("=");

            if (arg.length == 2) {
                arguments[arg[0]] = arg[1];
            }
        }

        arguments["name"] = fontWithArguments[0];

        if (fontDefElements.length > 3) {
            arguments["width"] = fontDefElements[fontDefElements.length - 3];
            arguments["height"] = fontDefElements[fontDefElements.length - 2];
        }

        return arguments;
    }

    ///Gets the (icon, size and color) for the given [imageDefinition] if it's a font icon.
    static ({Widget? icon, double? size, Color? color})? fromString(String? imageDefinition, [double? size, Color? color]) {
        if (imageDefinition == null || imageDefinition.isEmpty) {
            return null;
        }

        String? imageDefinition_ = imageDefinition;

        IconType? type;

        if (imageDefinition.startsWith(PREFIX_FONT_AWESOME)) {
            type = IconType.FontAwesome;
            imageDefinition_ = imageDefinition.substring(PREFIX_FONT_AWESOME.length);
        }
        else if (imageDefinition.startsWith(PREFIX_MATERIAL)) {
            type = IconType.Material;
            imageDefinition_ = imageDefinition.substring(PREFIX_MATERIAL.length);
        }

        if (type != null) {
            // name;arg=value;arg2=value2,width,height,dynamic

            List<String> fontDefElements = imageDefinition_.split(",");

            Map<String, String> arguments = {};

            String iconName;

            List<String> fontWithArguments = fontDefElements[0].split(";");

            iconName = fontWithArguments[0];

            Color? color_ = color;

            //for later usage
            void fillArguments() {
                for (int i = 1; i < fontWithArguments.length; i++) {
                    List<String> arg = fontWithArguments[i].split("=");

                    if (arg.length == 2) {
                        arguments[arg[0]] = arg[1];
                    }
                }
            }

            if (color_ == null) {
                //parse late!
                fillArguments();

                String? argColor = arguments["color"];

                if (argColor != null) {
                    color_ = ParseUtil.parseHexColor(argColor);
                }
            }

            double? size_ = size;

            if (size_ == null) {
                if (fontDefElements.length > 3) {
                    //use height if width is not a valid number (shouldn't happen)
                    size_ = double.tryParse(fontDefElements[fontDefElements.length - 3]) ?? double.tryParse(fontDefElements[fontDefElements.length - 2]);
                }
                else {
                    //parse if not already parsed!
                    if (color == null) {
                        fillArguments();
                    }
                    String? argSize = arguments["size"];

                    if (argSize != null) {
                        size_ = double.tryParse(argSize);
                    }
                }
            }

            //dynamic property (properties[2]) is not relevant

            switch (type) {
                case IconType.Material:
                    Icon? icon = MaterialIconUtil.getIcon(iconName, size_, color_);

                    if (icon != null) {
                        return (icon: icon, size: icon.size, color: icon.color);
                    }
                case IconType.FontAwesome:
                    FaIcon? icon = FontAwesomeUtil.getIcon(iconName, size_, color_);

                    if (icon != null) {
                        return (icon: icon, size: icon.size, color: icon.color);
                    }
            }
        }

        return null;
    }

    ///Gets whether the given [imageDefinition] is a font icon definition.
    static bool isFontIcon(dynamic imageDefinition) {
        if (imageDefinition is! String) {
            return false;
        }

        if (imageDefinition.isEmpty) {
            return false;
        }

        if (imageDefinition.startsWith(PREFIX_FONT_AWESOME)) {
            return true;
        }
        else if (imageDefinition.startsWith(PREFIX_MATERIAL)) {
            return true;
        }

        return false;
    }

    ///Gets prefix of font icon definition
    static String? getFontIconPrefix(dynamic imageDefinition) {
        if (imageDefinition is! String) {
            return null;
        }

        if (imageDefinition.isEmpty) {
            return null;
        }

        if (imageDefinition.startsWith(PREFIX_FONT_AWESOME)) {
            return PREFIX_FONT_AWESOME;
        }
        else if (imageDefinition.startsWith(PREFIX_MATERIAL)) {
            return PREFIX_MATERIAL;
        }

        return null;
    }

    /// Gets an image for an icon
    static Future<({MemoryImage image, Size size})> iconToImageProvider(
      IconData icon, {
      double? fontSize,
      Color? color,
      double? scaleFactor,
    }) async {
      final textPainter = TextPainter(textDirection: TextDirection.ltr);

      double fontSize_ = fontSize ?? 48.0;
      Color color_ = color ?? Colors.black;
      double scaleFactor_ = scaleFactor ?? 4.0;

      textPainter.text = TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: fontSize_ * scaleFactor_,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: color_,
        ),
      );

    textPainter.layout();
    final Size renderedSize = textPainter.size;

    final pictureRecorder = ui.PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final paint = Paint()
          ..colorFilter = ui.ColorFilter.mode(color_, ui.BlendMode.srcIn);
      canvas.saveLayer(Offset.zero & renderedSize, paint);
    textPainter.paint(canvas, Offset.zero);
      canvas.restore();

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(
        renderedSize.width.ceil(),
        renderedSize.height.ceil(),
    );

    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);

    return (
      image: MemoryImage(
        bytes!.buffer.asUint8List(),
        scale: scaleFactor_
      ),
      size: Size(
        renderedSize.width / scaleFactor_,
        renderedSize.height / scaleFactor_,
      ),
    );
  }

}
