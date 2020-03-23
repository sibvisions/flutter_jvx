import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/api/response/response_data.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/data/select_record.dart';
import '../../model/api/request/press_button.dart';
import '../../model/api/request/request.dart';
import '../../ui/screen/component_data.dart';
import '../../model/action.dart' as jvxAction;
import '../../model/api/request/data/meta_data.dart' as dataModel;

mixin DataScreen {
  BuildContext context;
  List<ComponentData> componentData = <ComponentData>[];

  void updateData(Request request, ResponseData pData) {

    if(request is SelectRecord && request.requestType==RequestType.DAL_DELETE) {
      ComponentData cData = getComponentData(request.dataProvider);
      cData.data.deleteLocalRecord(request.filter);
    }

    if (request==null || request?.requestType!=RequestType.DAL_SET_VALUE) {
      pData.jVxData?.forEach((d) {
        ComponentData cData = getComponentData(d.dataProvider);
        cData.updateData(d, request.reload);
      });

      pData.jVxMetaData?.forEach((m) {
        ComponentData cData = getComponentData(m.dataProvider);
        cData.updateMetaData(m);
      });

      pData.jVxDataproviderChanged?.forEach((d) {
        ComponentData cData = getComponentData(d.dataProvider);
        cData.updateDataProviderChanged(context, d);
      });

      componentData.forEach((d) {
        if (d.metaData==null && !d.isFetchingMetaData) {
          d.isFetchingMetaData = true;
          dataModel.MetaData meta = dataModel.MetaData(d.dataProvider);
          BlocProvider.of<ApiBloc>(context).dispatch(meta);
        }
      });
    }

    if (request != null && request.requestType==RequestType.DAL_SELECT_RECORD && (request is SelectRecord)) {
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
      //data.addToRequestQueue = this._addToRequestQueue;
      componentData.add(data);
    }

    return data;
  }

  void onButtonPressed(String componentId, String label) {
    // wait until textfields focus lost. 10 millis should do it.
    Future.delayed(const Duration(milliseconds: 10), () {
      PressButton pressButton = PressButton(jvxAction.Action(componentId: componentId, label: label));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });
  }
}