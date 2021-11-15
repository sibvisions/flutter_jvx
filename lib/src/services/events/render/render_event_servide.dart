import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_jvx/src/layout/border_layout.dart';
import 'package:flutter_jvx/src/layout/form_layout.dart';
import 'package:flutter_jvx/src/models/events/render/register_parent_event.dart';
import 'package:flutter_jvx/src/models/events/render/register_preferred_size_event.dart';
import 'package:flutter_jvx/src/models/events/render/unregister_parent_event.dart';
import 'package:flutter_jvx/src/models/layout/layout_child.dart';
import 'package:flutter_jvx/src/models/layout/layout_data.dart';
import 'package:flutter_jvx/src/models/layout/layout_parent.dart';
import 'package:flutter_jvx/src/services/events/i_render_service.dart';

class RenderEventService extends IRenderService {
  final List<LayoutParent> parents = [];

  @override
  void receivedRegisterParentEvent(RegisterParentEvent event) {
    //check if parent already exits
    if (parents.every((element) => element.id == event.id)) {
    } else {
      //Builds Children with only Id, so the preferred Size can be added later.
      List<LayoutChild> children = event.childrenIds
          .map((e) => LayoutChild(id: e, parentId: event.id))
          .toList();
      parents.add(
          LayoutParent(id: event.id, layout: event.layout, children: children));
    }
  }

  @override
  void receivedRegisterPreferredSizeEvent(RegisterPreferredSizeEvent event) {
    //Find correct Child
    LayoutParent parent =
        parents.firstWhere((element) => element.id == event.parent);
    LayoutChild child =
        parent.children.firstWhere((element) => element.id == event.id);

    //Set PreferredSize and constraints
    child.preferredSize = event.size;
    child.constraints = event.constraints;

    //DeepCopy to make sure data can't be changed by other events while checks and calculation are running
    LayoutParent parentSnapShot = LayoutParent(
        children: [...parent.children], id: parent.id, layout: parent.layout);

    bool legalLayoutState = parentSnapShot.children
        .every((element) => element.preferredSize != null);

    if (legalLayoutState) {
      _performCalculation(parentSnapShot);
    }
  }

  //TODO IF A PARENT SETS ITS CHILD SIZE AND HAS TO RE-LAYOUT ITSELF ACCORDINGLY THIS NEEDS TO BE IMPLEMENTED.!

  _performCalculation(LayoutParent parent) {
    Future? layoutData;

    //Use compute(new Isolate) to not lock app while layout is calculating
    if (parent.layout == "BorderLayout") {
      layoutData = compute(BorderLayout.calculateLayout, parent);
    } else if (parent.layout == "FormLayout") {
      layoutData = compute(FormLayout.calculateLayout, parent);
    }

    //register callback on compute completion
    if (layoutData != null) {
      layoutData.then((value) => {log(value.toString())});
    }
  }

  @override
  void receivedUnregisterParentEvent(UnregisterParentEvent event) {
    parents.removeWhere((element) => element.id == event.id);
  }

  _sendLayoutCommand(String id, LayoutConstraints layoutData) {}
}
