import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/component/icon/fl_icon_model.dart';
import 'package:flutter_client/util/constants/i_color.dart';
import 'package:flutter_client/util/image/image_loader.dart';

import '../../model/layout/alignments.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlIconWidget<T extends FlIconModel> extends FlStatelessWidget<T> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  final bool imageInBinary;

  final ImageStreamListener? imageStreamListener;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget({Key? key, required T model, this.imageInBinary = false, this.imageStreamListener})
      : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    Widget? child = getImage();

    if (model.tooltipText != null) {
      child = Tooltip(message: model.tooltipText!, child: child);
    }

    return Container(
      child: FittedBox(
        child: child,
        fit: getBoxFit(),
        alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
      ),
      decoration: BoxDecoration(color: model.background),
    );

    // return Container(
    //   child: child,
    //   alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
    //   decoration: BoxDecoration(color: model.background),
    // );
  }

  BoxFit getBoxFit() {
    if (model.horizontalAlignment == HorizontalAlignment.STRETCH &&
        model.verticalAlignment == VerticalAlignment.STRETCH) {
      if (model.preserveAspectRatio) {
        return BoxFit.contain;
      } else {
        return BoxFit.fill;
      }
    } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH) {
      return BoxFit.fitWidth;
    } else if (model.verticalAlignment == VerticalAlignment.STRETCH) {
      return BoxFit.fitHeight;
    }

    return BoxFit.none;
  }

  Widget? getImage() {
    //BoxConstraints constraints) {
    // Size size = Size(constraints.maxWidth, constraints.maxHeight);

    // HorizontalAlignment hAlign = model.horizontalAlignment;
    // VerticalAlignment vAlign = model.verticalAlignment;
    // if (IFontAwesome.checkFontAwesome(model.image)) {
    //   if (hAlign == HorizontalAlignment.STRETCH) {
    //     hAlign = HorizontalAlignment.CENTER;
    //   }
    //   if (vAlign == VerticalAlignment.STRETCH) {
    //     vAlign = VerticalAlignment.CENTER;
    //   }
    // }

    // double iWidth = hAlign == HorizontalAlignment.STRETCH ? size.width : model.originalSize.width;
    // double iHeight = vAlign == VerticalAlignment.STRETCH ? size.height : model.originalSize.height;

    // if (model.preserveAspectRatio) {
    //   if (model.horizontalAlignment == HorizontalAlignment.STRETCH &&
    //       model.verticalAlignment != VerticalAlignment.STRETCH) {
    //     iHeight = (iWidth / model.originalSize.width) * model.originalSize.height;
    //   } else if (model.horizontalAlignment != HorizontalAlignment.STRETCH &&
    //       model.verticalAlignment == VerticalAlignment.STRETCH) {
    //     iWidth = (iHeight / model.originalSize.height) * model.originalSize.width;
    //   } else if (model.horizontalAlignment == HorizontalAlignment.STRETCH &&
    //       model.verticalAlignment == VerticalAlignment.STRETCH) {
    //     iWidth = (iHeight / model.originalSize.height) * model.originalSize.width;

    //     if (iWidth > size.width) {
    //       iWidth = size.width;
    //     }

    //     iHeight = (iWidth / model.originalSize.width) * model.originalSize.height;
    //   }
    // }

    // return ImageLoader.loadImage(model.image,
    //     pWantedSize: Size(iWidth, iHeight), pWantedColor: model.isEnabled ? null : IColorConstants.COMPONENT_DISABLED);

    if (model.image.isNotEmpty) {
      return ImageLoader.loadImage(
        model.image,
        pWantedColor: model.isEnabled ? null : IColorConstants.COMPONENT_DISABLED,
        pImageStreamListener: imageStreamListener,
      );
    }
  }
}
