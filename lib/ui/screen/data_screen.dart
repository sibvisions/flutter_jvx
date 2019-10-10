


import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/ui/screen/component_data.dart';

class DataScreen {
  List<ComponentData> componentData = <ComponentData>[];

  void updateData(List<JVxData> data, List<JVxMetaData> metaData) {

    data?.forEach((d) {
      ComponentData cData = getComponentData(d.dataProvider);
      cData.updateData(d);
    });

    metaData?.forEach((m) {
      ComponentData cData = getComponentData(m.dataProvider);
      cData.updateMetaData(m);
    });
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