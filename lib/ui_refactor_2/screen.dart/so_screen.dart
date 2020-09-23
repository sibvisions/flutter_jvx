import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/data/data_book.dart';
import 'package:jvx_flutterclient/model/api/response/response_data.dart';

import 'component_screen_widget.dart';
import 'i_component_creator.dart';
import 'i_screen.dart';

class SoScreen extends StatelessWidget implements IScreen {
  String title = "OpenScreen";
  Key componentId;
  List<DataBook> data = <DataBook>[];
  List<MetaData> metaData = <MetaData>[];
  Function buttonCallback;
  ComponentScreenWidget componentScreen;

  IComponentCreator componentCreator;

  Request currentRequest;
  ResponseData currentResponseData;

  SoScreen({Key key, IComponentCreator componentCreator})
      : componentCreator = componentCreator,
        super(key: key);

  @override
  void update(Request request, ResponseData responseData) {
    if (request != null) currentRequest = request;
    if (responseData != null) currentResponseData = responseData;
    // componentScreen.state?.updateData(request, responseData);
    // if (responseData.screenGeneric != null)
    //   componentScreen.state
    //       ?.updateComponents(responseData.screenGeneric.changedComponents);
  }

  @override
  bool withServer() {
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: ComponentScreenWidget(
          key: this.componentId,
          componentCreator: this.componentCreator,
          request: currentRequest,
          responseData: currentResponseData,
        ));
  }
}
