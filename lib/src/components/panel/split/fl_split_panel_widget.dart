import 'package:flutter/widgets.dart';

import '../../../layout/split_layout.dart';
import '../../../model/component/panel/fl_split_panel_model.dart';
import '../../../model/layout/layout_position.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../fl_panel_widget.dart';
import '../scroll/fl_scroll_panel_widget.dart';

class FlSplitPanelWidget extends FlPanelWidget<FlSplitPanelModel> {
  final SplitLayout layout;

  final ScrollController firstVerticalcontroller;
  final ScrollController firstHorizontalController;
  final ScrollController secondVerticalController;
  final ScrollController secondHorizontalController;

  const FlSplitPanelWidget({
    super.key,
    required super.model,
    required this.layout,
    required this.firstVerticalcontroller,
    required this.firstHorizontalController,
    required this.secondVerticalController,
    required this.secondHorizontalController,
    required super.children,
  });

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
      ScrollController horizontalController;
      ScrollController verticalController;
      if (childWidget.model.constraints == SplitLayout.FIRST_COMPONENT) {
        viewerPosition = layout.firstComponentViewer;
        childPosition = layout.firstComponentSize;
        horizontalController = firstHorizontalController;
        verticalController = firstVerticalcontroller;
      } else {
        viewerPosition = layout.secondComponentViewer;
        childPosition = layout.secondComponentSize;
        horizontalController = secondHorizontalController;
        verticalController = secondVerticalController;
      }

      bool isScrollable = viewerPosition.width < childPosition.width || viewerPosition.height < childPosition.height;

      children.add(
        Positioned(
          top: viewerPosition.top,
          left: viewerPosition.left,
          width: viewerPosition.width,
          height: viewerPosition.height,
          child: FlScrollPanelWidget(
            model: model,
            isScrollable: isScrollable,
            width: childPosition.width,
            height: childPosition.height,
            viewWidth: viewerPosition.width,
            viewHeight: viewerPosition.height,
            horizontalScrollController: horizontalController,
            verticalScrollController: verticalController,
            children: [childWidget],
          ),
        ),
      );
    }

    return Stack(
      children: children,
    );
  }
}
