/*
 * Copyright 2026 SIB Visions GmbH
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

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../model/response/record_format.dart';
import '../../../util/image/image_loader.dart';
import '../../util/data_context.dart';
import '../fl_list_entry.dart';

class ListImage extends StatelessWidget {

  final String? columnName;
  final dynamic imageDefinition;

  final Uint8List? bytes;
  final double? radius;
  final dynamic icon;
  final Color? iconColor;
  final Color? iconBackgroundColor;

  const ListImage({
    super.key,
    this.columnName,
    this.radius,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor
  }) : imageDefinition = null,
        bytes = null;

  const ListImage.predefined({
    super.key,
    this.imageDefinition,
    this.bytes,
    this.radius,
    this.icon,
    this.iconColor,
    this.iconBackgroundColor
  }) : columnName = null;

  @override
  Widget build(BuildContext context) {
    double radius_ = radius ?? 30;

    Uint8List? bytes_ = bytes;
    dynamic imageDefinition_ = imageDefinition;

    Color? iconColor_ = iconColor;

    if (columnName != null) {
      DataContext? dc = DataContext.of(context);

      if (dc != null) {
        FlListEntry entry = dc.data;

        dynamic result = entry.getValue(columnName);

        if (result is Uint8List) {
          bytes_ = result;
        }
        else if (result is String) {
          imageDefinition_ = result;
        }

        CellFormat? format = entry.getCellFormat(columnName);

        if (format != null) {
          iconColor_ = format.foreground;
        }
      }
    }

    if (bytes_ != null || imageDefinition_ != null) {
      return CircleAvatar(
        minRadius: radius_,
        backgroundImage: ImageLoader.getImageProvider(bytes_ ?? imageDefinition_),
      );
    }

    return CircleAvatar(
        radius: radius_,
        backgroundColor: iconBackgroundColor ?? Colors.grey.shade300,
        child: Icon(icon ?? Icons.person,
            size: radius_ * 1.5,
            color: iconColor_ ?? Colors.grey.shade700));
  }
}
