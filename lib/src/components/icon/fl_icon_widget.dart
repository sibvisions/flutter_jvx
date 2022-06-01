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

  final VoidCallback? onPress;

  final Widget? directImage;

  final bool imageInBinary;

  final Function(Size, bool)? imageStreamListener;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget(
      {Key? key,
      required T model,
      this.imageInBinary = false,
      this.imageStreamListener,
      this.directImage,
      this.onPress})
      : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    Widget? child = directImage ?? getImage();

    if (model.tooltipText != null) {
      child = Tooltip(message: model.tooltipText!, child: child);
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        child: FittedBox(
          child: child,
          fit: getBoxFit(),
          alignment: FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index],
        ),
        decoration: BoxDecoration(color: model.background),
      ),
    );
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

    if (model.preserveAspectRatio) {
      return BoxFit.contain;
    } else {
      return BoxFit.fill;
    }
  }

  Widget? getImage() {
    return ImageLoader.loadImage(model.image,
        pWantedColor: model.isEnabled ? null : IColorConstants.COMPONENT_DISABLED,
        pImageStreamListener: imageStreamListener,
        imageInBinary: imageInBinary);
  }
}
