import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import 'models/component_model.dart';

class ComponentWidget extends StatefulWidget {
  final ComponentModel componentModel;

  ComponentWidget({Key key, @required this.componentModel}) : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      ComponentWidgetState<ComponentWidget>();
}

class ComponentWidgetState<T extends StatefulWidget> extends State<T> {
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

    (widget as ComponentWidget).componentModel.addListener(() => setState(() {}));
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
