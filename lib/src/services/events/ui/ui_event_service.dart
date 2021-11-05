import 'dart:developer';

import 'package:flutter_jvx/src/models/events/menu/menu_button_pressed_event.dart';
import 'package:flutter_jvx/src/models/events/meta/startup_event.dart';
import 'package:flutter_jvx/src/models/events/ui/login_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_login_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_menu_button_pressed_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_startup_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/api_service_mixin.dart';

class UiEventService with OnStartupEvent, OnLoginEvent, OnMenuButtonPressedEvent, ApiServiceMixin {


  UiEventService() {
    startupEventStream.listen(_receivedStartupEvent);
    loginEventStream.listen(_receivedLoginEvent);
    menuButtonPressedEventStream.listen(_receivedMenuButtonPressed);
  }

  _receivedStartupEvent(StartupEvent event) {
    var a = apiRepository.startUp();
    apiController.determineResponse(a);
  }

  _receivedLoginEvent(LoginEvent event) {
    var a = apiRepository.login(event.username, event.password);
    apiController.determineResponse(a);
  }

  _receivedMenuButtonPressed(MenuButtonPressedEvent event) {
    var a = apiRepository.openScreen(event.componentId);
    apiController.determineResponse(a);
  }

}