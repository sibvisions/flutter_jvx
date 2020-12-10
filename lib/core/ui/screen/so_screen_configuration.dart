import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';

class SoScreenConfiguration extends ValueNotifier<Response> {
  final String componentId;
  final String screenTitle;
  final bool withServer;

  SoScreenConfiguration(Response response,
      {@required this.componentId,
      @required this.screenTitle,
      this.withServer = true})
      : super(response);
}
