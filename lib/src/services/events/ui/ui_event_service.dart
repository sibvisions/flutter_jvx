import 'dart:developer';

import 'package:flutter_jvx/src/models/events/menu/menu_button_pressed_event.dart';
import 'package:flutter_jvx/src/models/events/meta/startup_event.dart';
import 'package:flutter_jvx/src/models/events/ui/login_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_login_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_menu_button_pressed_event.dart';
import 'package:flutter_jvx/src/util/mixin/events/ui/on_startup_event.dart';
import 'package:flutter_jvx/src/util/mixin/service/api_mixin.dart';

class UiEventService with OnStartupEvent, OnLoginEvent, OnMenuButtonPressedEvent, ApiMixin {


  UiEventService() {
    startupEventStream.listen(_receivedStartupEvent);
    loginEventStream.listen(_receivedLoginEvent);
    menuButtonPressedEventStream.listen(_receivedMenuButtonPressed);
  }

  _receivedStartupEvent(StartupEvent event) {
    apiService.startUp();
  }

  _receivedLoginEvent(LoginEvent event) {

  }

  _receivedMenuButtonPressed(MenuButtonPressedEvent event) {
    apiService.openScreen(event.componentId);
  }

}