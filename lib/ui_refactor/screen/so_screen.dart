import 'package:flutter/material.dart';
import 'package:jvx_flutterclient/ui_refactor/component/component_widget.dart';
import '../../model/api/response/response_data.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/data/data_book.dart';
import '../../model/api/response/meta_data/data_book_meta_data.dart';
import '../../model/api/response/screen_generic.dart';
import 'component_screen_widget.dart';
import 'i_component_creator.dart';

class SoScreen {
  String title = "OpenScreen";
  Key componentId;
  List<DataBook> data = <DataBook>[];
  List<MetaData> metaData = <MetaData>[];
  Function buttonCallback;
  ComponentScreenWidget componentScreen;

  SoScreen(IComponentCreator componentCreator)
      : componentScreen = ComponentScreenWidget(
          componentCreator: componentCreator,
        );

  void update(Request request, ResponseData responseData) {
    componentScreen.of().updateData(request, responseData);
    if (responseData.screenGeneric != null)
      componentScreen
          .of()
          .updateComponents(responseData.screenGeneric.changedComponents);
  }

  Widget getWidget() {
    if (componentScreen.of().debug)
      componentScreen.of().debugPrintCurrentWidgetTree();

    ComponentWidget component = componentScreen.of().getRootComponent();

    if (component != null) {
      return FractionallySizedBox(
          widthFactor: 1, heightFactor: 1, child: component);
    } else {
      return Container(
        alignment: Alignment.center,
        child: Text('No root component defined!'),
      );
    }
  }

  bool withServer() {
    return true;
  }
}
