/*
 * Copyright 2022 SIB Visions GmbH
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
import 'package:photo_view/photo_view.dart';

import '../../../flutter_jvx.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/layout/alignments.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlIconWidget<T extends FlIconModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final VoidCallback? onPress;

  final Widget? image;

  final Function(Size, bool)? imageStreamListener;

  final bool inTable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget({
    super.key,
    required super.model,
    this.image,
    this.imageStreamListener,
    this.onPress,
    this.inTable = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget? child = image ?? _loadImage();

    if (model.toolTipText != null) {
      child = Tooltip(message: model.toolTipText!, child: child);
    }

    if (onPress != null) {
      return GestureDetector(
        onTap: model.isEnabled ? onPress : null,
        child: DecoratedBox(
          decoration: BoxDecoration(color: model.background),
          child: child,
        ),
      );
    } else {
      return GestureDetector(
        onTap: image == null && !IconUtil.isFontIcon(model.image)
            ? () => showDialog(
                  context: context,
                  builder: (context) {
                    return GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: PhotoView(
                        backgroundDecoration: const BoxDecoration(
                          color: Colors.transparent,
                        ),
                        initialScale: PhotoViewComputedScale.contained * 0.75,
                        minScale: PhotoViewComputedScale.contained * 0.1,
                        imageProvider: ImageLoader.getImageProvider(model.image),
                      ),
                    );
                  },
                )
            : null,
        child: DecoratedBox(
          decoration: BoxDecoration(color: model.background),
          child: child,
        ),
      );
    }
  }

  BoxFit? getBoxFit() {
    if (inTable) {
      return BoxFit.scaleDown;
    }

    if (model.preserveAspectRatio) {
      if ((model.horizontalAlignment == HorizontalAlignment.STRETCH) &&
          (model.verticalAlignment == VerticalAlignment.STRETCH)) {
        return BoxFit.contain;
      } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
        return BoxFit.fitWidth;
      } else if (model.verticalAlignment == VerticalAlignment.STRETCH) {
        return BoxFit.fitHeight;
      }
    } else {
      if ((model.horizontalAlignment == HorizontalAlignment.STRETCH) &&
          (model.verticalAlignment == VerticalAlignment.STRETCH)) {
        return BoxFit.fill;
      } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH ||
          model.verticalAlignment == VerticalAlignment.STRETCH) {
        return null;
      }
    }
    return BoxFit.none;
  }

  Widget? _loadImage() {
    if (model.image == null || model.image!.isEmpty) {
      return null;
    }

    BoxFit? boxFit = getBoxFit();

    if (boxFit == null) {
      return LayoutBuilder(builder: (context, constraints) {
        double width = model.originalSize.width;
        double height = model.originalSize.height;

        if (boxFit == null) {
          if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
            width = constraints.maxWidth;
          }
          if (model.verticalAlignment == VerticalAlignment.STRETCH) {
            height = constraints.maxHeight;
          }
        }

        return Align(
          alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
          child: SizedBox(
            width: width,
            height: height,
            child: ImageLoader.loadImage(
              model.image!,
              imageStreamListener: imageStreamListener,
              color: model.isEnabled ? model.foreground : JVxColors.COMPONENT_DISABLED,
              fit: BoxFit.fill,
            ),
          ),
        );
      });
    } else {
      return ImageLoader.loadImage(
        model.image!,
        imageStreamListener: imageStreamListener,
        color: model.isEnabled ? model.foreground : JVxColors.COMPONENT_DISABLED,
        fit: boxFit,
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      );
    }
  }
}
