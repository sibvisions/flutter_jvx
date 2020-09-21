import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/model/api/request/request.dart';
import 'package:jvx_flutterclient/model/api/response/data/data_book.dart';
import 'package:jvx_flutterclient/model/api/response/response_data.dart';

import 'component_screen_widget.dart';
import 'i_component_creator.dart';
import 'i_screen.dart';

class SoScreen implements IScreen {
  String title = "OpenScreen";
  Key componentId;
  List<DataBook> data = <DataBook>[];
  List<MetaData> metaData = <MetaData>[];
  Function buttonCallback;
  ComponentScreenWidget componentScreen;

  IComponentCreator componentCreator;

  SoScreen(IComponentCreator componentCreator)
      : componentCreator = componentCreator;

  @override
  void update(Request request, ResponseData responseData) {
    // componentScreen.state?.updateData(request, responseData);
    // if (responseData.screenGeneric != null)
    //   componentScreen.state
    //       ?.updateComponents(responseData.screenGeneric.changedComponents);
  }

  @override
  Widget getWidget(Request request, ResponseData responseData) {
    // if (componentScreen.state != null && componentScreen.state.debug)
    //   componentScreen.state?.debugPrintCurrentWidgetTree();

    // if (componentScreen != null) {
    return FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: ComponentScreenWidget(
          componentCreator: this.componentCreator,
          request: request,
          responseData: responseData,
        ));
    // } else {
    //   return Container(
    //     alignment: Alignment.center,
    //     child: Text('No root component defined!'),
    //   );
    // }
  }

  @override
  bool withServer() {
    return true;
  }
}
