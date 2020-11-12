import 'package:flutter/material.dart';

import '../../../../core/models/api/request.dart';
import '../../../../core/models/api/response/response_data.dart';
import '../../../../core/ui/screen/i_screen.dart';
import '../../../../core/utils/app/listener/application_api.dart';
import '../../../../core/utils/app/listener/data_api.dart';

/// Implementation of [IScreen] for custom screens.
class CustomScreen extends StatelessWidget implements IScreen {
  final String _templateName;

  CustomScreen(this._templateName);

  @override
  void update(Request request, ResponseData data) {}

  @override
  bool withServer() {
    return true;
  }

  DataApi getDataApi(String dataProvider) {
    // return DataApi(componentScreen.getComponentData(dataProvider),
    //     componentScreen.context);
  }

  ApplicationApi getApplicationApi(BuildContext context) {
    return ApplicationApi(context);
  }

  // void setHeader(ComponentWidget headerComponent) {
  //   componentScreen.setHeader(headerComponent);
  // }

  // void setFooter(ComponentWidget footerComponent) {
  //   componentScreen.setFooter(footerComponent);
  // }

  String getTemplateName() {
    return _templateName;
  }

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('No custom screen returned'));
  }
}
