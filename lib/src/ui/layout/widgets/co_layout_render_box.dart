import 'dart:developer';

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

  // Size? getChildLayoutPreferredSize(RenderBox renderBox) {
  //   //renderBox.layout(BoxConstraints.tightForFinite(), parentUsesSize: true);

  //   if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
  //     CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

  //     log("$debugInfo returns preferredLayoutSize ${childLayout.preferredLayoutSize}");
  //     return childLayout.preferredLayoutSize;
  //   }

  //   return null;
  // }

  Size? getChildLayoutPreferredSize(
      ComponentWidget componentWidget, BoxConstraints constraints) {
    if (componentWidget is CoContainerWidget) {
      return (componentWidget.componentModel as ContainerComponentModel)
          .layout
          ?.layoutModel
          .layoutPreferredSize[constraints];
    }
  }

  // Size? getChildLayoutMinimumSize(RenderBox renderBox) {
  //   if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
  //     CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

  //     return childLayout.minimumLayoutSize;
  //   }

  //   return null;
  // }

  Size? getChildLayoutMinimumSize(
      ComponentWidget componentWidget, BoxConstraints constraints) {
    if (componentWidget is CoContainerWidget) {
      return (componentWidget.componentModel as ContainerComponentModel)
          .layout
          ?.layoutModel
          .layoutMinimumSize[constraints];
    }
  }

  // Size? getChildLayoutMaximumSize(RenderBox renderBox) {
  //   if (renderBox is RenderShiftedBox && renderBox.child is CoLayoutRenderBox) {
  //     CoLayoutRenderBox childLayout = renderBox.child as CoLayoutRenderBox;

  //     return childLayout.maximumLayoutSize;
  //   }

  //   return null;
  // }

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
        //if (renderBox.hasSize) return renderBox.size;
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

        if (size != null) {
          boxConstraints = BoxConstraints(
              minHeight: constraints.minHeight,
              minWidth: constraints.minWidth,
              maxHeight: constraints.maxHeight,
              maxWidth: double.maxFinite);

          renderBox.layout(normalizeConstraints(boxConstraints),
              parentUsesSize: true);

          size = Size(size.width, renderBox.size.height);
        }
      }
    } else {
      if(constraints.hasInfiniteWidth){
        renderBox.layout(normalizeConstraints(BoxConstraints(minHeight: constraints.maxHeight, maxHeight: constraints.maxHeight)), parentUsesSize: true);
      } else if(constraints.hasBoundedHeight) {
        renderBox.layout(normalizeConstraints(BoxConstraints(minWidth: constraints.minWidth, maxWidth: constraints.maxWidth )), parentUsesSize: true);
      } else {
        renderBox.layout(normalizeConstraints(constraints), parentUsesSize: true);
      }
      return renderBox.size;
    }

    return size;
  }

  BoxConstraints normalizeConstraints(BoxConstraints constraints) {
    //return constraints;
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
