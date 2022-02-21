import 'package:flutter/material.dart';
import 'package:flutter_client/src/components/base_wrapper/base_comp_wrapper_widget.dart';
import 'package:flutter_client/src/components/base_wrapper/fl_stateless_widget.dart';
import 'package:flutter_client/src/layout/split_layout.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/component/panel/fl_split_panel_model.dart';
import 'package:flutter_client/src/model/layout/layout_position.dart';

class FlSplitPanelWidget extends FlStatelessWidget<FlSplitPanelModel> with UiServiceMixin {
  final SplitLayout layout;

  FlSplitPanelWidget({Key? key, required this.layout, required FlSplitPanelModel model, required this.children})
      : super(key: key, model: model);

  final List<Widget> children;

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
                // IgnorePointer(
                //   ignoring: true,
                // child:
                SizedBox(
                  width: childPosition.width,
                  height: childPosition.height,
                  // ),
                ),
                childWidget
              ],
            ),
          ),
        ),
      );
    }

    return Stack(
      children: children,
    );
  }
}
