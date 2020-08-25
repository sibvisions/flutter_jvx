import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../model/api/response/response_data.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../model/api/request/data/select_record.dart';
import '../../model/api/request/press_button.dart';
import '../../model/api/request/request.dart';
import 'so_component_data.dart';
import '../../model/so_action.dart';
import '../../model/api/request/data/meta_data.dart' as dataModel;

mixin SoDataScreen {
  BuildContext context;
  List<SoComponentData> componentData = <SoComponentData>[];
  List<Request> requestQueue = <Request>[];

  void updateData(Request request, ResponseData pData) {
    if (request is SelectRecord &&
        request.requestType == RequestType.DAL_DELETE) {
      SoComponentData cData = getComponentData(request.dataProvider);
      cData.data.deleteLocalRecord(request.filter);
    }

    if (request == null || request?.requestType != RequestType.DAL_SET_VALUE) {
      pData.dataBooks?.forEach((d) {
        SoComponentData cData = getComponentData(d.dataProvider);
        cData.updateData(d, request.reload);
      });

      pData.dataBookMetaData?.forEach((m) {
        SoComponentData cData = getComponentData(m.dataProvider);
        cData.updateMetaData(m);
      });

      componentData.forEach((d) {
        if (d.metaData == null && !d.isFetchingMetaData) {
          d.isFetchingMetaData = true;
          dataModel.MetaData meta = dataModel.MetaData(d.dataProvider);
          BlocProvider.of<ApiBloc>(context).dispatch(meta);
        }
      });

      if (requestQueue.length > 0) {
        if (requestQueue.first is SelectRecord) {
          SelectRecord selectRecord = (requestQueue.first as SelectRecord);
          requestQueue.removeAt(0);
          selectRecord = selectRecord.soComponentData.getSelectRecordRequest(
              context, selectRecord.selectedRow, selectRecord.fetch);
          BlocProvider.of<ApiBloc>(context).dispatch(selectRecord);
        }
      }
    }

    pData.dataproviderChanged?.forEach((d) {
      SoComponentData cData = getComponentData(d.dataProvider);
      cData.updateDataProviderChanged(context, d);
    });

    if (request != null &&
        request.requestType == RequestType.DAL_SELECT_RECORD &&
        (request is SelectRecord)) {
      SoComponentData cData = getComponentData(request.dataProvider);
      cData?.updateSelectedRow(request.selectedRow);
    }
  }

  SoComponentData getComponentData(String dataProvider) {
    SoComponentData data;
    if (componentData.length > 0)
      data = componentData.firstWhere((d) => d.dataProvider == dataProvider,
          orElse: () => null);

    if (data == null) {
      data = SoComponentData(dataProvider, this);
      //data.addToRequestQueue = this._addToRequestQueue;
      componentData.add(data);
    }

    return data;
  }

  void onButtonPressed(String componentId, String label) {
    // wait until textfields focus lost. 10 millis should do it.
    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton =
          PressButton(SoAction(componentId: componentId, label: label));
      BlocProvider.of<ApiBloc>(context).dispatch(pressButton);
    });
  }

  void requestNext() {
    if (requestQueue.length > 0) {
      BlocProvider.of<ApiBloc>(context).dispatch(requestQueue.first);
      requestQueue.removeAt(0);
    }
  }
}
