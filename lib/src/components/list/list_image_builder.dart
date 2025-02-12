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
  _ListImage buildCustom({
    ChildWidgetBuilder? childBuilder,
    required BuildContext context,
    required JsonWidgetData data,
    Key? key,
  });
}

class _ListImage extends StatelessWidget {
  final String? imageDefinition;
  final Uint8List? bytes;
  final double? width;
  final double? height;

  const _ListImage({
    this.imageDefinition,
    this.bytes,
    this.width,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    if (bytes != null) {
      return Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                  fit: BoxFit.cover,
                  image: MemoryImage(bytes!),
              )),
          width: width ?? 60,
          height: height ?? 60);
    } else if (imageDefinition != null) {
        return ClipRRect(
            borderRadius: BorderRadius.circular(30.0),
            child: ImageLoader.loadImage(imageDefinition!, width: width ?? 60, height: height ?? 60),
        );
    }
    else {
      return CircleAvatar(
          radius: max(width ?? 30, height ?? 30),
          backgroundColor: Colors.grey.shade300,
          child: Icon(Icons.person, size: max(width ?? 45, height ?? 45), color: Colors.grey.shade700));
    }
  }
}
