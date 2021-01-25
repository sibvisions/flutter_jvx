import 'package:flutter/material.dart';

import '../../models/api/response.dart';

class SoScreenConfiguration extends ValueNotifier<Response> {
  final String componentId;
  final String screenTitle;
  final bool withServer;
  final String screenComponentId;

  SoScreenConfiguration(Response response,
      {@required this.componentId,
      @required this.screenTitle,
      this.screenComponentId = "",
      this.withServer = true})
      : super(response);
}
