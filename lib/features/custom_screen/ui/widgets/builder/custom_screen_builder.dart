import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/component/changed_component.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_component_data.dart';

typedef ChangedComponentBuilder = Widget Function(BuildContext context, ChangedComponent changedComponent, SoComponentData data);