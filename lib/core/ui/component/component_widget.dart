import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../injection_container.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/app/app_state.dart';
import '../../utils/app/so_text_style.dart';
import '../../utils/theme/hex_color.dart';
import '../container/container_component_model.dart';
import '../screen/component_screen_widget.dart';
import 'component_model.dart';

class ComponentWidget extends StatefulWidget {
  final ComponentModel componentModel;

  ComponentWidget({Key key, @required this.componentModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      ComponentWidgetState<ComponentWidget>();
}

class ComponentWidgetState<T extends StatefulWidget> extends State<T> {
  String name;
  String rawComponentId;
  CoState state = CoState.Free;
  Color background = Colors.transparent;
  Color foreground;
  TextStyle style = new TextStyle(fontSize: 16.0, color: Colors.black);
  Size _preferredSize;
  Size _minimumSize;
  Size _maximumSize;
  bool isVisible = true;
  bool enabled = true;
  String constraints = "";
  int verticalAlignment = 1;
  int horizontalAlignment = 0;

  String parentComponentId;
  List<Key> childComponentIds;

  AppState appState;

  bool get isForegroundSet => foreground != null;
  bool get isBackgroundSet => background != null;
  bool get isPreferredSizeSet => preferredSize != null;
  bool get isMinimumSizeSet => minimumSize != null;
  bool get isMaximumSizeSet => maximumSize != null;
  Size get preferredSize => _preferredSize;
  set preferredSize(Size size) => _preferredSize = size;
  Size get minimumSize => _minimumSize;
  set minimumSize(Size size) => _minimumSize = size;
  Size get maximumSize => _maximumSize;
  set maximumSize(Size size) => _maximumSize = size;

  void updateProperties(ChangedComponent changedComponent) {
    preferredSize = changedComponent.getProperty<Size>(
        ComponentProperty.PREFERRED_SIZE, _preferredSize);
    maximumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MAXIMUM_SIZE, _maximumSize);
    minimumSize = changedComponent.getProperty<Size>(
        ComponentProperty.MINIMUM_SIZE, _minimumSize);
    rawComponentId = changedComponent.getProperty<String>(ComponentProperty.ID);
    background =
        changedComponent.getProperty<HexColor>(ComponentProperty.BACKGROUND);
    name = changedComponent.getProperty<String>(ComponentProperty.NAME, name);
    isVisible =
        changedComponent.getProperty<bool>(ComponentProperty.VISIBLE, true);
    style = SoTextStyle.addFontToTextStyle(
        changedComponent.getProperty<String>(ComponentProperty.FONT, ""),
        style);
    foreground = changedComponent.getProperty<HexColor>(
        ComponentProperty.FOREGROUND, null);
    style = SoTextStyle.addForecolorToTextStyle(foreground, style);
    enabled =
        changedComponent.getProperty<bool>(ComponentProperty.ENABLED, true);
    parentComponentId = changedComponent.getProperty<String>(
        ComponentProperty.PARENT, parentComponentId);
    constraints = changedComponent.getProperty<String>(
        ComponentProperty.CONSTRAINTS, constraints);
    verticalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.VERTICAL_ALIGNMENT, verticalAlignment);
    horizontalAlignment = changedComponent.getProperty<int>(
        ComponentProperty.HORIZONTAL_ALIGNMENT, horizontalAlignment);
  }

  void _update() {
    if ((widget as ComponentWidget).componentModel.firstChangedComponent !=
        null)
      this.updateProperties(
          (widget as ComponentWidget).componentModel.firstChangedComponent);

    (widget as ComponentWidget)
        .componentModel
        .toUpdateComponents
        .forEach((toUpdateComponent) {
      this.updateProperties(toUpdateComponent.changedComponent);
    });

    (widget as ComponentWidget).componentModel.toUpdateComponents =
        Queue<ToUpdateComponent>();

    state = (widget as ComponentWidget).componentModel.coState;
    constraints = (widget as ComponentWidget).componentModel.constraints;
  }

  @override
  void setState(fn) {
    SchedulerBinding.instance.addPostFrameCallback((timeStamp) {
      if (mounted) {
        super.setState(fn);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
    this.appState = sl<AppState>();

    this._update();
    (widget as ComponentWidget).componentModel.componentState = this;
    (widget as ComponentWidget).componentModel.addListener(() {
      setState(() => this._update());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
