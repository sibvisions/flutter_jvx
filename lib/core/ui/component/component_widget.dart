import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../injection_container.dart';
import '../../models/api/component/changed_component.dart';
import '../../models/api/component/component_properties.dart';
import '../../models/app/app_state.dart';
import '../container/container_component_model.dart';
import 'models/component_model.dart';

class ComponentWidget extends StatefulWidget {
  final ComponentModel componentModel;

  ComponentWidget({Key key, @required this.componentModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      ComponentWidgetState<ComponentWidget>();
}

class ComponentWidgetState<T extends StatefulWidget> extends State<T> {
  AppState appState;

  void updateProperties(ChangedComponent changedComponent) {}

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
