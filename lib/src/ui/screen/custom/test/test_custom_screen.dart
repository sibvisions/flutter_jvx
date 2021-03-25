import 'package:flutter/material.dart';
import 'package:flutterclient/src/ui/screen/core/configuration/so_screen_configuration.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_creator.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';
import 'package:flutterclient/src/ui/screen/custom/custom_screen.dart';

class TestCustomScreen extends CustomScreen {
  TestCustomScreen(
      {required SoScreenConfiguration configuration,
      required SoComponentCreator creator})
      : super(configuration: configuration, creator: creator);

  @override
  SoScreenState<SoScreen> createState() => TestCustomScreenState();
}

class TestCustomScreenState extends CustomScreenState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text('Custom screen test!'),
      ),
    );
  }
}
