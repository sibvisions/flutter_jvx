import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/new_bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/changed_component.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/services/data_service.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';
import 'package:jvx_mobile_v3/ui/component/i_component.dart';
import 'package:jvx_mobile_v3/ui/screen/component_screen.dart';
import 'package:jvx_mobile_v3/ui/screen/i_component_creator.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class JVxScreen extends ComponentScreen {
  String title = "OpenScreen";
  Key componentId;
  List<JVxData> data = <JVxData>[];
  List<JVxMetaData> metaData = <JVxMetaData>[];
  Function buttonCallback;

  JVxScreen(IComponentCreator componentCreator) : super(componentCreator);
  
  void selectRecord(String dataProvider, int index, [bool fetch = false]) {
    DataService dataService = DataService(RestClient());

    JVxData selectData = this.getData(dataProvider);

    if (selectData != null && index < selectData.records.length) {
      dataService
          .selectRecord(dataProvider, selectData.columnNames,
              selectData.records[index], fetch, globals.clientId)
          .then((val) =>
              getIt.get<JVxScreen>("screen").buttonCallback(val.updatedComponents));
    }
  }

  void setValues(
      String dataProvider, List<dynamic> columnNames, List<dynamic> value) {
    DataService dataService = DataService(RestClient());

    dataService
        .setValues(dataProvider, columnNames, value, globals.clientId)
        .then((val) {
      print("CHANGEDCOMPONENTS" + val.changedComponents.toString());
      this.updateComponents(val.changedComponents);
      buttonCallback(val.changedComponents);
    });
  }

  JVxData getData(String dataProvider,
      [List<dynamic> columnNames, int reload]) {
    DataService dataService = DataService(RestClient());

    JVxData returnData;


    print('DATAPROVDER: ' + (dataProvider != null ? dataProvider : ""));

    if (dataProvider != null) {
      data.forEach((d) {
        if (d.dataProvider == dataProvider) returnData = d;
      });
    }

    if ((returnData == null || reload == -1) &&
        dataProvider != null &&
        columnNames != null) {
      dataService
          .getData(dataProvider, globals.clientId, columnNames, null, null)
          .then((JVxData jvxData) {
        data.add(jvxData);
        buttonCallback(<ChangedComponent>[]);
      });

      return null;
    } else {
      return returnData;
    }
  }

  Widget getWidget() {
    if (debug) debugPrintCurrentWidgetTree();

    IComponent component = this.getRootComponent();

    if (component != null) {
      return component.getWidget();
    } else {
      // ToDO
      return Container(
        alignment: Alignment.center,
        child: Text('No root component defined!'),
      );
    }
  }
}
