import 'package:flutter/material.dart';

import 'package:jvx_flutterclient/jvx_flutterclient.dart';

class ScreenArguments {
  final String title;
  final ResponseData responseData;
  final Key componentId;
  final Request request;
  final String menuComponentId;
  final String templateName;
  final List<MenuItem> items;

  ScreenArguments(
    this.title,
    this.responseData,
    this.componentId,
    this.request,
    this.menuComponentId,
    this.templateName,
    this.items,
  );
}
