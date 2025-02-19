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

import 'dart:math';

import 'package:avatars/avatars.dart';
import 'package:json_dynamic_widget/json_dynamic_widget.dart';

import '../../../flutter_jvx.dart';

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
  final String? imageDefinition;
  final Uint8List? bytes;
  final double? radius;

  const ListImage({
    super.key,
    this.imageDefinition,
    this.bytes,
    this.radius,
  });

  @override
  Widget build(BuildContext context) {
    double radius_ = radius ?? 30;

    if (bytes != null) {
      return CircleAvatar(
        minRadius: radius_,
        backgroundImage: MemoryImage(bytes!),
      );
    } else if (imageDefinition != null) {
      return CircleAvatar(
          minRadius: radius_,
          backgroundImage: ImageLoader.getImageProvider(imageDefinition!));
    }
    else {
      return CircleAvatar(
          radius: radius_,
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.person,
              size: radius_ * 1.5,
              color: Colors.grey.shade700));
    }
  }
}
