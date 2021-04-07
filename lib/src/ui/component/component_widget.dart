import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/component/model/component_model.dart';

class ComponentWidget extends StatefulWidget {
  final ComponentModel componentModel;

  const ComponentWidget({Key? key, required this.componentModel})
      : super(key: key);

  @override
  State<StatefulWidget> createState() =>
      ComponentWidgetState<ComponentWidget>();
}

class ComponentWidgetState<T extends ComponentWidget> extends State<T> {
  void onModelChange() {
    setState(() {});
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();

    widget.componentModel.addListener(onModelChange);
  }

  @override
  void dispose() {
    widget.componentModel.removeListener(onModelChange);

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Text('Please overwrite the build method!'),
      ),
    );
  }
}
