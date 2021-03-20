import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_flutterclient/core/models/api/request/close_screen.dart';
import 'package:jvx_flutterclient/core/models/api/request/navigation.dart';
import 'package:jvx_flutterclient/core/models/api/request/set_component_value.dart';
import 'package:jvx_flutterclient/core/models/api/response.dart';
import 'package:jvx_flutterclient/core/models/api/response/error_response.dart';
import 'package:jvx_flutterclient/core/models/app/app_state.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/i_offline_database_provider.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/local_database.dart';
import 'package:jvx_flutterclient/core/services/local/local_database/offline_database.dart';
import 'package:jvx_flutterclient/core/services/local/local_database_manager.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_screen.dart';
import 'package:jvx_flutterclient/core/ui/widgets/dialogs/dialogs.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/error_handling.dart';
import 'package:jvx_flutterclient/core/ui/widgets/util/shared_pref_provider.dart';
import 'package:jvx_flutterclient/core/utils/app/text_utils.dart';
import 'package:jvx_flutterclient/core/utils/translation/app_localizations.dart';
import 'package:jvx_flutterclient/injection_container.dart';

import '../../models/api/request.dart';
import '../../models/api/request/data/fetch_data.dart';
import '../../models/api/request/data/meta_data.dart' as dataModel;
import '../../models/api/request/data/select_record.dart';
import '../../models/api/request/data/set_values.dart';
import '../../models/api/request/press_button.dart';
import '../../models/api/response/response_data.dart';
import '../../models/api/so_action.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../widgets/util/app_state_provider.dart';
import 'so_component_data.dart';

mixin SoDataScreen {
  List<SoComponentData> componentData = <SoComponentData>[];
  List<Request> requestQueue = <Request>[];

  void updateData(BuildContext context, Request request, ResponseData pData) {
    if (request is SelectRecord &&
        request.requestType == RequestType.DAL_DELETE) {
      SoComponentData cData = getComponentData(request.dataProvider);
      cData.data.deleteLocalRecord(request.filter);
    }

    if (request == null || request?.requestType != RequestType.DAL_SET_VALUE) {
      pData.dataBooks?.forEach((d) {
        SoComponentData cData = getComponentData(d.dataProvider);
        cData.updateData(context, d, request.reload);
      });

      pData.dataBookMetaData?.forEach((m) {
        SoComponentData cData = getComponentData(m.dataProvider);
        cData.updateMetaData(m);
      });

      componentData.forEach((d) {
        if (d.metaData == null && !d.isFetchingMetaData) {
          d.isFetchingMetaData = true;
          dataModel.MetaData meta = dataModel.MetaData(
              d.dataProvider, AppStateProvider.of(context).appState.clientId);
          BlocProvider.of<ApiBloc>(context).add(meta);
        }
      });
    }

    if (request != null &&
        request.requestType == RequestType.DAL_SET_VALUE &&
        request is SetValues) {
      pData.dataBooks?.forEach((element) {
        SoComponentData cData = getComponentData(element.dataProvider);
        cData.updateData(context, pData.dataBooks[0]);
        // Commented out by Jürgen: Not sure if we need this?
        // if (request.filter != null &&
        //     request.filter.values != null &&
        //     request.filter.values.length > 0)
        //   cData.updateSelectedRow(context, request.filter.values[0]);
      });
    }

    // execute delayed select after reload data
    if (requestQueue.length > 0) {
      if (requestQueue.first is SelectRecord &&
          (requestQueue.first as SelectRecord).soComponentData != null) {
        SelectRecord selectRecord = (requestQueue.first as SelectRecord);
        bool allowDelayedSelect = true;

        pData.dataproviderChanged.forEach((d) {
          if (selectRecord.soComponentData.dataProvider == d.dataProvider) {
            allowDelayedSelect = false;
          }
        });

        if (request.requestType == RequestType.DAL_FETCH &&
            (request is FetchData) &&
            request.dataProvider != selectRecord.dataProvider) {
          allowDelayedSelect = false;
        }

        if (allowDelayedSelect) {
          requestQueue.removeAt(0);
          if (selectRecord.soComponentData.data != null &&
              selectRecord.soComponentData.data.records != null &&
              selectRecord.soComponentData.data.records.length >
                  selectRecord.selectedRow) {
            selectRecord = selectRecord.soComponentData.getSelectRecordRequest(
                context, selectRecord.selectedRow, selectRecord.fetch);
            BlocProvider.of<ApiBloc>(context).add(selectRecord);
          }
        }
      }
    }

    pData.dataproviderChanged?.forEach((d) {
      SoComponentData cData = getComponentData(d.dataProvider);
      cData.updateDataProviderChanged(context, d, request.requestType);
    });

    if (request != null &&
        request.requestType == RequestType.DAL_SELECT_RECORD &&
        (request is SelectRecord)) {
      SoComponentData cData = getComponentData(request.dataProvider);
      cData?.updateSelectedRow(context, request.selectedRow);
    }

    //this.testOfflineDB(context, request, pData);
  }

  // Future<void> testOfflineDB(
  //     BuildContext context, Request request, ResponseData pData) async {
  //   String path = AppStateProvider.of(context).appState.dir + "/offlineDB.db";

  //   OfflineDatabase db = await LocalDatabaseManager.localDatabaseManager
  //       .getDatabase<OfflineDatabase>(() => new OfflineDatabase(), path);

  //   await Future.forEach(pData.dataBookMetaData, (m) async {
  //     await db.createTableWithMetaData(m, this.so);
  //   });

  //   await Future.forEach(pData.dataBooks, (d) async {
  //     await db.importRows(d);
  //   });
  // }

  SoComponentData getComponentData(String dataProvider) {
    SoComponentData data;
    if (componentData.length > 0)
      data = componentData.firstWhere((d) => d.dataProvider == dataProvider,
          orElse: () => null);

    if (data == null && dataProvider != null) {
      data = SoComponentData(dataProvider, this);
      //data.addToRequestQueue = this._addToRequestQueue;
      componentData.add(data);
    }

    return data;
  }

  Future<void> showOfflineError(
      BuildContext context, ErrorResponse response) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(response.title),
            content: Text(response.message),
            actions: <Widget>[
              FlatButton(
                child: Text(AppLocalizations.of(context).text('Close')),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }

  void goOffline(BuildContext context, Response response) async {
    BlocProvider.of<ApiBloc>(context).removeAllCallbacks();

    response.responseData.dataproviderChanged?.forEach((d) {
      getComponentData(d.dataProvider);
    });
    response.responseData.dataBooks?.forEach((d) {
      SoComponentData cData = getComponentData(d.dataProvider);
      cData.updateData(context, d, response.request.reload);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) => hideProgress(context));

    try {
      if (!response.hasError) {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => showLinearProgressIndicator(context));
        String path =
            AppStateProvider.of(context).appState.dir + "/offlineDB.db";

        bool importSuccess =
            await sl<IOfflineDatabaseProvider>().openCreateDatabase(path);

        if (importSuccess)
          importSuccess = importSuccess &
              await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                  .importComponents(context, componentData);

        (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
            .removeAllProgressCallbacks();

        if ((sl<IOfflineDatabaseProvider>() as OfflineDatabase).responseError !=
            null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            hideLinearProgressIndicator(context);
            showOfflineError(
                context,
                (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                    .responseError
                    .error);
          });

          await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
              .cleanupDatabase();
        } else if (importSuccess) {
          hideLinearProgressIndicator(context);

          SharedPrefProvider.of(context).manager.setOffline(true);
          AppState appState = AppStateProvider.of(context).appState;

          appState.offline = true;

          BlocProvider.of<ApiBloc>(context).add(CloseScreen(
            clientId: appState.clientId,
            componentId: appState.currentScreenComponentId,
            requestType: RequestType.CLOSE_SCREEN,
          ));
          BlocProvider.of<ApiBloc>(context).add(Navigation());
        }
      } else {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => hideLinearProgressIndicator(context));
      }
    } catch (e) {
      try {
        WidgetsBinding.instance
            .addPostFrameCallback((_) => hideProgress(context));
        WidgetsBinding.instance
            .addPostFrameCallback((_) => hideLinearProgressIndicator(context));
        WidgetsBinding.instance
            .addPostFrameCallback((_) => hideLinearProgressIndicator(context));
        SharedPrefProvider.of(context).manager.setOffline(false);
        AppState appState = AppStateProvider.of(context).appState;

        appState.offline = false;
        await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
            .cleanupDatabase();
      } catch (ee) {}
      rethrow;
    }
  }

  void onAction(BuildContext context, SoAction action) async {
    TextUtils.unfocusCurrentTextfield(context);

    // wait until textfields focus lost. 10 millis should do it.
    Future.delayed(const Duration(milliseconds: 100), () {
      PressButton pressButton =
          PressButton(action, AppStateProvider.of(context).appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(pressButton);
    });
  }

  void onComponetValueChanged(
      BuildContext context, String componentId, dynamic value) {
    TextUtils.unfocusCurrentTextfield(context);

    // wait until textfields focus lost. 10 millis should do it.
    Future.delayed(const Duration(milliseconds: 100), () {
      SetComponentValue setComponentValue = SetComponentValue(
          componentId, value, AppStateProvider.of(context).appState.clientId);
      BlocProvider.of<ApiBloc>(context).add(setComponentValue);
    });
  }

  void requestNext(BuildContext context) {
    if (requestQueue.length > 0) {
      BlocProvider.of<ApiBloc>(context).add(requestQueue.first);
      requestQueue.removeAt(0);
    }
  }
}
