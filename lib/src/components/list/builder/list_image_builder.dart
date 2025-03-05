/*
 * Copyright 2025 SIB Visions GmbH
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
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../../flutter_jvx.dart';
import '../../../model/response/record_format.dart';

part 'list_image_builder.g.dart';

//dart run build_runner build --delete-conflicting-outputs

@jsonWidget
abstract class _ListImageBuilder extends JsonWidgetBuilder {
  const _ListImageBuilder({
    required super.args,
  });

  @override
  ListImage buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  });
}

class ListImage extends StatelessWidget {
  final JsonWidgetData? data;

  final String? columnName;
  final String? imageDefinition;
  final Uint8List? bytes;
  final double? radius;
  final IconData? icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ListImage({
    @JsonBuildArg() required this.data,
    super.key,
    this.columnName,
    this.imageDefinition,
    this.bytes,
    this.radius,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor
  });

  const ListImage.predefined({
    super.key,
    this.imageDefinition,
    this.bytes,
    this.radius,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor
  }) : data = null, columnName = null;

  @override
  Widget build(BuildContext context) {
    double radius_ = radius ?? 30;

    Uint8List? bytes_ = bytes;
    String? imageDefinition_ = imageDefinition;

    Color? iconColor_ = iconColor;

    if (columnName != null && data != null) {
      JsonWidgetFunction? func = data?.jsonWidgetRegistry.getFunction("getValue");

      if (func != null) {
        dynamic result = func(args: [columnName], registry: data!.jsonWidgetRegistry);

        if (result is Uint8List) {
          bytes_ = result;
        }
        else if (result is String) {
          imageDefinition_ = result;
        }
      }

      func = data?.jsonWidgetRegistry.getFunction("getCellFormat");

      if (func != null) {
        dynamic result = func(args: [columnName], registry: data!.jsonWidgetRegistry);

        if (result is CellFormat) {
          iconColor_ = result.foreground;
        }
      }
    }

    if (bytes_ != null) {
      return CircleAvatar(
        minRadius: radius_,
        backgroundImage: MemoryImage(bytes_),
      );
    } else if (imageDefinition_ != null) {
      return CircleAvatar(
          minRadius: radius_,
          backgroundImage: ImageLoader.getImageProvider(imageDefinition_));
    }

    return CircleAvatar(
        radius: radius_,
        backgroundColor: iconBackgroundColor ?? Colors.grey.shade300,
        child: Icon(icon ?? Icons.person,
            size: radius_ * 1.5,
            color: iconColor_ ?? Colors.grey.shade700));
  }
}
