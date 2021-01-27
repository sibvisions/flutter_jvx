import 'package:flutter/material.dart';

import '../../models/api/response.dart';

class SoScreenConfiguration extends ValueNotifier<Response> {
  String componentId;
  String screenTitle;
  bool withServer;
  String screenComponentId;
  bool offlineScreen;
  bool Function() onBack;

  SoScreenConfiguration(Response response,
      {@required this.componentId,
      @required this.screenTitle,
      this.offlineScreen,
      this.onBack,
      this.screenComponentId = "",
      this.withServer = true})
      : super(response);
}
