import 'package:flutter/material.dart';
import '../../model/api/response/response_data.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/data/data_book.dart';
import '../../model/api/response/meta_data/data_book_meta_data.dart';
import '../../model/api/response/screen_generic.dart';
import '../component/i_component.dart';
import 'so_component_screen.dart';
import 'i_component_creator.dart';
import 'i_screen.dart';

class SoScreen implements IScreen {
  String title = "OpenScreen";
  Key componentId;
  List<DataBook> data = <DataBook>[];
  List<MetaData> metaData = <MetaData>[];
  Function buttonCallback;
  SoComponentScreen componentScreen;

  SoScreen(IComponentCreator componentCreator)
      : componentScreen = SoComponentScreen(componentCreator);

  @override
  void update(Request request, ResponseData responseData) {
    componentScreen.updateData(request, responseData);
    if (responseData.screenGeneric != null)
      componentScreen
          .updateComponents(responseData.screenGeneric.changedComponents);
  }

  @override
  Widget getWidget() {
    if (componentScreen.debug) componentScreen.debugPrintCurrentWidgetTree();

    IComponent component = this.componentScreen.getRootComponent();

    if (component != null) {
      return FractionallySizedBox(
          widthFactor: 1, heightFactor: 1, child: component.getWidget());
    } else {
      return Container(
        alignment: Alignment.center,
        child: Text('No root component defined!'),
      );
    }
  }

  @override
  bool withServer() {
    return true;
  }
}
