import 'package:flutter/material.dart';
import 'package:flutter_jvx/src/models/api/component/ui_component_model.dart';

class UIPanelWrapper extends StatefulWidget {
  const UIPanelWrapper({Key? key, required this.model}) : super(key: key);

  final UiComponentModel model;

  @override
  _UIPanelWrapperState createState() => _UIPanelWrapperState();
}

class _UIPanelWrapperState extends State<UIPanelWrapper> {

  bool sentPreferredSize = false;



  @override
  Widget build(BuildContext context) {
    if(!sentPreferredSize){

    }
    return Container();
  }
}
