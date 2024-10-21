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

import '../../flutter_jvx.dart';
import 'font_awesome_util.dart';
import 'material_icons_util.dart';

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

            if (color_ == null) {
                for (int i = 1; i < fontWithArguments.length; i++) {
                    List<String> arg = fontWithArguments[i].split("=");

                    if (arg.length == 2) {
                        arguments[arg[0]] = arg[1];
                    }
                }

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
    static bool isFontIcon(String? imageDefinition) {
        if (imageDefinition == null || imageDefinition.isEmpty) {
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
}
