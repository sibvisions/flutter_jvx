import 'package:flutter/material.dart';

import '../../core/configuration/so_screen_configuration.dart';
import '../../core/so_component_creator.dart';
import '../../core/so_screen.dart';
import '../custom_screen.dart';

class TestOnlineCustomScreen extends CustomScreen {
  TestOnlineCustomScreen(
      {required SoScreenConfiguration configuration,
      required SoComponentCreator creator})
      : super(configuration: configuration, creator: creator);

  @override
  SoScreenState<SoScreen> createState() => TestOnlineCustomScreenState();
}

class TestOnlineCustomScreenState extends CustomScreenState {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}
