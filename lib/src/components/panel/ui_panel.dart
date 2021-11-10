import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';
import 'package:flutter_jvx/src/services/events/render/render_event_servide.dart';

class UiPanel extends StatefulWidget {

  const UiPanel({
    Key? key,
  }) : super(key: key);

  @override
  _UiPanelState createState() => _UiPanelState();
}

class _UiPanelState extends State<UiPanel>{




  @override
  void didUpdateWidget(covariant UiPanel oldWidget) {
    log("asdasd");
    super.didUpdateWidget(oldWidget);
  }


  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
