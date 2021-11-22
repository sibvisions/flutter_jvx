import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/components/panel/ui_panel.dart';
import 'package:flutter_jvx/src/components/ui_components_factory.dart';
import 'package:flutter_jvx/src/layout/form_layout.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/models/events/render/register_parent_event.dart';
import 'package:flutter_jvx/src/models/events/render/register_preferred_size_event.dart';
import 'package:flutter_jvx/src/models/layout/layout_position.dart';
import 'package:flutter_jvx/src/util/mixin/events/render/on_register_parent_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/render/on_register_preferred_size_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/component_store_sevice_mixin.dart';

class UIPanelWrapper extends StatefulWidget {
  const UIPanelWrapper({Key? key, required this.model}) : super(key: key);

  final UiComponentModel model;

  @override
  _UIPanelWrapperState createState() => _UIPanelWrapperState();
}

class _UIPanelWrapperState extends State<UIPanelWrapper>
    with OnRegisterParentEvent, OnRegisterPreferredSizeEvent, ComponentStoreServiceMixin {
  bool sentPreferredSize = false;
  LayoutPosition? layoutPosition;
  List<Widget> children = [];
  List<UiComponentModel> childrenId = [];

  @override
  void initState() {
    childrenId = componentStoreService.getChildrenById(widget.model.id);
    if (childrenId.isNotEmpty) {
      RegisterParentEvent event = RegisterParentEvent(
          origin: this,
          reason: "Panel has been initialised",
          id: widget.model.id,
          layout: FormLayout(),
          layoutData: "",
          childrenIds: childrenId.map((e) => e.id).toList(),
          layoutInsets: '');
      fireRegisterParentEvent(event);
    } else if (widget.model.parent != null && widget.model.constraints != null) {
      RegisterPreferredSizeEvent event = RegisterPreferredSizeEvent(
          origin: this,
          reason: "Panel was empty, so 0,0 size will be sent",
          id: widget.model.id,
          parent: widget.model.parent!,
          size: const Size(0, 0),
          constraints: widget.model.constraints!);
      fireRegisterPreferredSizeEvent(event);
    }
    children = childrenId.map((e) => UIComponentFactory.createWidgetFromModel(e)).toList();
    super.initState();
  }

  //only gets called when its children are fully laid out -by Render Service Event-
  void getChildSizes(Map<String, LayoutPosition> layoutPosition) {
    List<Widget> newLayout = [];

    //UiComponentList should be always the same order the Widget children are in.
    for (int i = 0; i < children.length; i++) {
      List<UiComponentModel> childrenData = componentStoreService.getChildrenById(widget.model.id);
    }

    setState(() {
      children = newLayout;
    });
  }

  Widget _createPositionChildren(LayoutPosition? layoutPosition, Widget child) {
    return Container();
  }

  @override
  Widget build(BuildContext context) {
    return UIPanel(children: children, key: Key(widget.model.id));
  }
}
