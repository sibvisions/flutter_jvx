import 'package:flutter/material.dart';

import '../../models/api/response.dart';

MaterialColor getColorFromAppStyle(Response state) {
  Map<int, Color> color = {
    50: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .1),
    100: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .2),
    200: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .3),
    300: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .4),
    400: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .5),
    500: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .6),
    600: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .7),
    700: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .8),
    800: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        .9),
    900: Color.fromRGBO(
        state.applicationStyle.themeColor.red,
        state.applicationStyle.themeColor.green,
        state.applicationStyle.themeColor.blue,
        1),
  };

  MaterialColor colorCustom =
      MaterialColor(state.applicationStyle.themeColor.value, color);
  return colorCustom;
}
