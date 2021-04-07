import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/application_style/application_style_response_object.dart';

MaterialColor? getColorFromAppStyle(ApplicationStyleResponseObject state) {
  if (state.themeColor != null) {
    Map<int, Color> color = {
      50: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .1),
      100: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .2),
      200: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .3),
      300: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .4),
      400: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .5),
      500: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .6),
      600: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .7),
      700: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .8),
      800: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, .9),
      900: Color.fromRGBO(state.themeColor!.red, state.themeColor!.green,
          state.themeColor!.blue, 1),
    };

    MaterialColor colorCustom = MaterialColor(state.themeColor!.value, color);
    return colorCustom;
  }
  return null;
}
