import 'package:flutter/widgets.dart';

import '../../../../components.dart';
import '../../../layout/split_layout.dart';
import '../../../model/layout/layout_position.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';

class FlSplitPanelWidget extends FlPanelWidget<FlSplitPanelModel> {
  final SplitLayout layout;

  const FlSplitPanelWidget({super.key, required super.model, required this.layout, required super.children});

  @override
  Widget build(BuildContext context) {
    //All layout information of our children.
    List<BaseCompWrapperWidget> childrenToWrap = [];

    for (Widget childWidget in children) {
      if (childWidget is BaseCompWrapperWidget) {
        childrenToWrap.add(childWidget);
      }
    }

    for (BaseCompWrapperWidget childWidget in childrenToWrap) {
      children.remove(childWidget);

      LayoutPosition viewerPosition;
      Size childPosition;
      if (childWidget.model.constraints == SplitLayout.FIRST_COMPONENT) {
        viewerPosition = layout.firstComponentViewer;
        childPosition = layout.firstComponentSize;
      } else {
        viewerPosition = layout.secondComponentViewer;
        childPosition = layout.secondComponentSize;
      }

      if (viewerPosition.width < childPosition.width || viewerPosition.height < childPosition.height) {
        children.add(
          Positioned(
            top: viewerPosition.top,
            left: viewerPosition.left,
            width: viewerPosition.width,
            height: viewerPosition.height,
            child: InteractiveViewer(
              constrained: false,
              child: Stack(
                children: [
                  IgnorePointer(
                    ignoring: true,
                    child: Container(
                      color: model.background,
                      width: childPosition.width,
                      height: childPosition.height,
                    ),
                  ),
                  childWidget
                ],
              ),
            ),
          ),
        );
      } else {
        children.add(
          Positioned(
            top: viewerPosition.top,
            left: viewerPosition.left,
            width: viewerPosition.width,
            height: viewerPosition.height,
            child: Stack(
              children: [
                IgnorePointer(
                  ignoring: true,
                  child: Container(
                    color: model.background,
                    width: childPosition.width,
                    height: childPosition.height,
                  ),
                ),
                childWidget
              ],
            ),
          ),
        );
      }
    }

    return Stack(
      children: children,
    );
  }
}
