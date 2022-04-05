import 'dart:developer';

import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/command/layout/set_component_size_command.dart';

import '../../model/command/api/device_status_command.dart';

import '../../components/components_factory.dart';
import '../../model/component/panel/fl_panel_model.dart';
import 'package:flutter/material.dart';


/// Screen used to show workScreens either custom or from the server,
/// will send a [DeviceStatusCommand] on open to account for
/// custom header/footer
class WorkScreen extends StatelessWidget with UiServiceMixin {

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /// Model of the upper-most parent in this screen
  final FlPanelModel screenModel;
  /// Widget of the screenModel
  final Widget screenWidget;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  WorkScreen({
    required this.screenModel,
    Key? key
  }) :
        screenWidget=ComponentsFactory.buildWidget(screenModel),
        super(key: key);

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        log("unfocused");
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(screenModel.id),
        ),
        body: Scaffold(
          backgroundColor: Theme
              .of(context)
              .backgroundColor,
          body: LayoutBuilder(builder: (context, constraints) {
            _setScreenSize(width: constraints.maxWidth, height: constraints.maxHeight);
            //ToDo send DeviceStatusRequest
            return Stack(
              children: [screenWidget],
            );
          }),
          resizeToAvoidBottomInset: false,
        ),
        resizeToAvoidBottomInset: false,
      ),
    );


    // Used for debugging when selecting widgets via the debugger or debugging
    // pointer events - because the GestureDetector eats all events

    //   return Scaffold(
    //     appBar: AppBar(title: Text(screenModel.name)),
    //     body: Scaffold(
    //       body: LayoutBuilder(builder: (context, constraints) {
    //         return Stack(
    //           children: [screenWidget],
    //         );
    //       }),
    //       resizeToAvoidBottomInset: false,
    //     ),
    //     resizeToAvoidBottomInset: false,
    //   );
    // }
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // User-defined methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  _setScreenSize({required double width, required double height}) {
    SetComponentSizeCommand command = SetComponentSizeCommand(
        componentId: screenModel.id,
        size: Size(width, height),
        reason: "Opened Work Screen"
    );

    uiService.sendCommand(command);
  }



}

