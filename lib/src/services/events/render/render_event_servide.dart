import 'dart:convert';
import 'dart:developer';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter_jvx/src/models/events/render/register_parent_event.dart';
import 'package:flutter_jvx/src/models/events/render/register_preferred_size_event.dart';
import 'package:flutter_jvx/src/models/events/render/unregister_parent_event.dart';
import 'package:flutter_jvx/src/services/events/i_render_service.dart';

class RenderEventService extends IRenderService {

  final List<Parent> parents = [];

  @override
  void receivedRegisterParentEvent(RegisterParentEvent event) {
    //check if parent already exits
    if(parents.every((element) => element.id == event.id)){

    } else {
      //Builds Children with only Id, so the preferred Size can be added later.
      List<Child> children = event.childrenIds.map((e) => Child(id: e)).toList();
      parents.add(Parent(id: event.id, layout: event.layout, children: children));
    }
  }

  @override
  void receivedRegisterPreferredSizeEvent(RegisterPreferredSizeEvent event) {
    Parent parent = parents.firstWhere((element) => element.id == event.parent);
    Child child = parent.children.firstWhere((element) => element.id == event.id);

    child.preferredSize = event.size;
    child.constraints = event.constraints;

    Parent parentSnapShot = Parent(children: [...parent.children], id: parent.id, layout: parent.layout);

  }

  @override
  void receivedUnregisterParentEvent(UnregisterParentEvent event) {

  }


  _sendLayoutCommand(String id, Size size) {

  }
}


class Parent {
  final String id;
  String layout;
  List<Child> children;

  Parent({
    required this.id,
    required this.layout,
    required this.children,
  });
}

class Child {
  final String id;
  String? constraints;
  Size? preferredSize;

  Child({
    required this.id,
    this.constraints,
    this.preferredSize
  });
}