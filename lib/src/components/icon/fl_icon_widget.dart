import 'package:flutter/material.dart';

import '../../../util/constants/i_color.dart';
import '../../../util/image/image_loader.dart';
import '../../model/component/icon/fl_icon_model.dart';
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

  final bool inTable;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  const FlIconWidget({
    Key? key,
    required T model,
    this.imageInBinary = false,
    this.imageStreamListener,
    this.directImage,
    this.onPress,
    this.inTable = false,
  }) : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    Widget? child = directImage ?? getImage();

    if (model.toolTipText != null) {
      child = Tooltip(message: model.toolTipText!, child: child);
    }

    Alignment? alignment = FLUTTER_ALIGNMENT[model.horizontalAlignment.index][model.verticalAlignment.index];

    if (model.horizontalAlignment == HorizontalAlignment.STRETCH ||
        model.verticalAlignment == VerticalAlignment.STRETCH) {
      alignment = null;
    }

    return GestureDetector(
      onTap: onPress,
      child: Container(
        alignment: alignment,
        decoration: BoxDecoration(color: model.background),
        child: child,
      ),
    );
  }

  BoxFit getBoxFit() {
    if (inTable) {
      return BoxFit.scaleDown;
    }

    if (model.preserveAspectRatio) {
      return BoxFit.contain;
    } else {
      return BoxFit.fill;
    }
  }

  Widget? getImage() {
    return ImageLoader.loadImage(
      model.image,
      pWantedColor: model.isEnabled ? null : IColorConstants.COMPONENT_DISABLED,
      pImageStreamListener: imageStreamListener,
      imageInBinary: imageInBinary,
      fit: getBoxFit(),
    );
  }
}
