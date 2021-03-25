import 'package:flutter/material.dart';
import 'package:flutterclient/src/services/remote/cubit/api_cubit.dart';

class SoScreenConfiguration extends ValueNotifier<ApiState> {
  String componentId;
  String screenTitle;
  String? templateName;
  bool withServer;
  bool offlineScreen;
  bool Function()? onBack;

  SoScreenConfiguration(
      {required ApiState response,
      required this.componentId,
      required this.screenTitle,
      this.onBack,
      this.templateName,
      this.offlineScreen = false,
      this.withServer = true})
      : super(response);
}
