import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterclient/flutterclient.dart';
import 'package:flutterclient/src/ui/component/component_widget.dart';
import 'package:flutterclient/src/ui/container/co_container_widget.dart';

class CoLayoutRenderBox extends RenderBox {
  // only used in parent layouts
  Size? preferredLayoutSize;
  Size? minimumLayoutSize;
  Size? maximumLayoutSize;
  bool valid = false;
  String debugInfo = "";

  Size? getChildLayoutPreferredSize(
      ComponentWidget componentWidget, BoxConstraints constraints) {
    if (componentWidget is CoContainerWidget) {
      return (componentWidget.componentModel as ContainerComponentModel)
          .layout
          ?.layoutModel
          .layoutPreferredSize[constraints];
    }
  }

  Size? getChildLayoutMinimumSize(
      ComponentWidget componentWidget, BoxConstraints constraints) {
    if (componentWidget is CoContainerWidget) {
      return (componentWidget.componentModel as ContainerComponentModel)
          .layout
          ?.layoutModel
          .layoutMinimumSize[constraints];
    }
  }

  Size? getChildLayoutMaximumSize(
      ComponentWidget componentWidget, BoxConstraints constraints) {
    if (componentWidget is CoContainerWidget) {
      return (componentWidget.componentModel as ContainerComponentModel)
          .layout!
          .layoutModel
          .layoutMaximumSize[constraints];
    }
  }

  Size layoutRenderBox(RenderBox renderBox, BoxConstraints constraints) {
    if (constraints.maxHeight == double.infinity &&
        constraints.maxWidth == double.infinity) {
      try {
        renderBox.layout(BoxConstraints.tightForFinite(), parentUsesSize: true);
        return renderBox.size;
      } catch (e) {
        BoxConstraints boxConstraints = BoxConstraints(
            minHeight: constraints.minHeight,
            minWidth: constraints.minWidth,
            maxHeight: double.maxFinite,
            maxWidth: constraints.maxWidth);

        renderBox.layout(normalizeConstraints(boxConstraints),
            parentUsesSize: true);
        Size size = renderBox.size;

        boxConstraints = BoxConstraints(
            minHeight: constraints.minHeight,
            minWidth: constraints.minWidth,
            maxHeight: constraints.maxHeight,
            maxWidth: double.maxFinite);

        renderBox.layout(normalizeConstraints(boxConstraints),
            parentUsesSize: true);
        size = Size(size.width, renderBox.size.height);
      }
    } else {
      BoxConstraints con = constraints;
      if (constraints.hasInfiniteWidth)
        con = BoxConstraints(
            minHeight: constraints.maxHeight,
            maxHeight: constraints.maxHeight,
            maxWidth: constraints.maxWidth);
      if (constraints.hasInfiniteHeight)
        con = BoxConstraints(
            minWidth: constraints.minWidth,
            maxWidth: constraints.maxWidth,
            maxHeight: constraints.maxHeight);

      renderBox.layout(normalizeConstraints(con), parentUsesSize: true);
      return renderBox.size;
    }
    return size;
  }

  BoxConstraints normalizeConstraints(BoxConstraints constraints) {
    double minWidth = constraints.minWidth < 0 ? 0 : constraints.minWidth;
    double maxWidth = constraints.maxWidth < 0 ? 0 : constraints.maxWidth;
    double minHeight = constraints.minHeight < 0 ? 0 : constraints.minHeight;
    double maxHeight = constraints.maxHeight < 0 ? 0 : constraints.maxHeight;

    if (minWidth > maxWidth) minWidth = maxWidth;
    if (minHeight > maxHeight) minHeight = maxHeight;

    return BoxConstraints(
        minWidth: minWidth,
        maxWidth: maxWidth,
        minHeight: minHeight,
        maxHeight: maxHeight);
  }
}
