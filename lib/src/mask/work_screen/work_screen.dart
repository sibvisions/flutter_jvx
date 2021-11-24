import '../../components/components_factory.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/panel/fl_panel_model.dart';
import 'package:flutter/material.dart';

class WorkScreen extends StatefulWidget {
  const WorkScreen({Key? key, required this.screen}) : super(key: key);

  final FlComponentModel screen;

  @override
  _WorkScreenState createState() => _WorkScreenState();
}

class _WorkScreenState extends State<WorkScreen> {


  Widget screen = const Text("dummy");

  @override
  void initState() {
    screen = ComponentsFactory.buildWidget(widget.screen);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text((widget.screen as FlPanelModel).screenClassName!)),
      body: screen,
    );
  }
}
