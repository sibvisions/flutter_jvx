import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/data/data_book.dart';
import 'package:jvx_flutterclient/model/api/response/response_data.dart';

import 'component_screen_widget.dart';
import 'i_component_creator.dart';
import 'i_screen.dart';

class SoScreen extends StatefulWidget implements IScreen {
  GlobalKey<SoScreenState> globalKey = GlobalKey();
  String title = "OpenScreen";
  Key componentId;
  List<DataBook> data = <DataBook>[];
  List<MetaData> metaData = <MetaData>[];
  Function buttonCallback;
  ComponentScreenWidget componentScreen;
  Request currentRequest;
  ResponseData currentResponseData;

  IComponentCreator componentCreator;

  SoScreen({@required this.globalKey, componentCreator})
      : componentCreator = componentCreator,
        super(key: globalKey);

  @override
  void update(Request request, ResponseData responseData) {
    if (globalKey.currentState != null) {
      globalKey.currentState.update(request, responseData);
    } else {
      this.currentRequest = request;
      this.currentResponseData = responseData;
    }
  }

  @override
  bool withServer() {
    return true;
  }

  @override
  State<StatefulWidget> createState() => SoScreenState(this.componentId,
      this.componentCreator, this.currentRequest, this.currentResponseData);
}

class SoScreenState extends State<SoScreen> {
  Key componentId;
  IComponentCreator componentCreator;
  Request currentRequest;
  ResponseData currentResponseData;

  SoScreenState(this.componentId, this.componentCreator, this.currentRequest,
      this.currentResponseData);

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

  void update(Request request, ResponseData responseData) {
    this.setState(() {
      if (request != null) currentRequest = request;
      if (responseData != null) currentResponseData = responseData;
    });

    // componentScreen.state?.updateData(request, responseData);
    // if (responseData.screenGeneric != null)
    //   componentScreen.state
    //       ?.updateComponents(responseData.screenGeneric.changedComponents);
  }
}
