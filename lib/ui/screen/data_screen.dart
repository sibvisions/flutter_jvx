
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/api/response/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';

class DataScreen {
  List<ComponentData> componentData = <ComponentData>[];

  void updateData(Request request, List<JVxData> data, List<JVxMetaData> metaData) {

    data?.forEach((d) {
      ComponentData cData = getComponentData(d.dataProvider);
      cData.updateData(d);
    });

    metaData?.forEach((m) {
      ComponentData cData = getComponentData(m.dataProvider);
      cData.updateMetaData(m);
    });

    if (request.requestType==RequestType.DAL_SELECT_RECORD && (request is SelectRecord)) {
      ComponentData cData = getComponentData(request.dataProvider);
      cData?.updateSelectedRow(request.selectedRow);
    }
  }

  ComponentData getComponentData(String dataProvider) {
    ComponentData data;
    if (componentData.length>0)
      data = componentData.firstWhere((d) => d.dataProvider == dataProvider, orElse: () => null);

    if (data==null) {
      data = ComponentData(dataProvider);
      componentData.add(data);
    }

    return data;
  }
}