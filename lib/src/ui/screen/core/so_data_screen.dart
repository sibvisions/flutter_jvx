import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutterclient/src/models/api/errors/failure.dart';
import 'package:flutterclient/src/models/api/requests/close_screen_request.dart';
import 'package:flutterclient/src/models/api/requests/navigation_request.dart';
import 'package:flutterclient/src/models/api/requests/open_screen_request.dart';
import 'package:flutterclient/src/models/state/app_state.dart';
import 'package:flutterclient/src/models/state/routes/pop_arguments/open_screen_page_pop_style.dart';
import 'package:flutterclient/src/models/state/routes/routes.dart';
import 'package:flutterclient/src/services/local/local_database/i_offline_database_provider.dart';
import 'package:flutterclient/src/services/local/local_database/offline_database.dart';
import 'package:flutterclient/src/ui/util/inherited_widgets/shared_preferences_provider.dart';
import 'package:flutterclient/src/ui/widgets/dialog/linear_progress_dialog.dart';
import 'package:flutterclient/src/util/translation/app_localizations.dart';

import '../../../../injection_container.dart';
import '../../../models/api/request.dart';
import '../../../models/api/requests/data/data_request.dart';
import '../../../models/api/requests/data/delete_record_request.dart';
import '../../../models/api/requests/data/fetch_data_request.dart';
import '../../../models/api/requests/data/meta_data_request.dart';
import '../../../models/api/requests/data/select_record_request.dart';
import '../../../models/api/requests/data/set_values_request.dart';
import '../../../models/api/requests/press_button_request.dart';
import '../../../models/api/requests/set_component_value.dart';
import '../../../models/api/response_object.dart';
import '../../../models/api/response_objects/response_data/data/data_book.dart';
import '../../../models/api/response_objects/response_data/data/dataprovider_changed.dart';
import '../../../models/api/response_objects/response_data/meta_data/data_book_meta_data.dart';
import '../../../services/remote/cubit/api_cubit.dart';
import '../../../util/app/text_utils.dart';
import '../../util/inherited_widgets/app_state_provider.dart';
import 'so_component_data.dart';

mixin SoDataScreen {
  List<SoComponentData> componentData = <SoComponentData>[];
  List<DataRequest> requestQueue = <DataRequest>[];

  void updateData(
      BuildContext context, Request request, List<ResponseObject> dataObjects) {
    List<DataBook> dataBooks = dataObjects.whereType<DataBook>().toList();
    List<DataBookMetaData> dataBookMetaDatas =
        dataObjects.whereType<DataBookMetaData>().toList();
    List<DataproviderChanged> dataProviderChanged =
        dataObjects.whereType<DataproviderChanged>().toList();

    if (request is DeleteRecordRequest) {
      SoComponentData cData = getComponentData(request.dataProvider);
      cData.data!.deleteLocalRecord(request.filter!);
    }

    if (!(request is SetValuesRequest)) {
      for (final d in dataBooks) {
        SoComponentData cData = getComponentData(d.dataProvider!);
        cData.updateData(context, d, request.reload);
      }

      for (final m in dataBookMetaDatas) {
        SoComponentData cData = getComponentData(m.dataProvider!);
        cData.updateMetaData(m);
      }

      for (final d in componentData) {
        if (d.metaData == null && !d.isFetchingMetaData) {
          d.isFetchingMetaData = true;
          MetaDataRequest meta = MetaDataRequest(
              dataProvider: d.dataProvider,
              clientId: AppStateProvider.of(context)!
                      .appState
                      .applicationMetaData
                      ?.clientId ??
                  '');

          sl<ApiCubit>().data(meta);
        }
      }
    }

    if (request is SetValuesRequest) {
      for (final d in dataBooks) {
        SoComponentData cData = getComponentData(d.dataProvider!);
        cData.updateData(context, dataBooks.first);
      }
    }

    if (requestQueue.isNotEmpty) {
      if (requestQueue.first is SelectRecordRequest &&
          (requestQueue.first as SelectRecordRequest).soComponentData != null) {
        SelectRecordRequest selectRecord =
            requestQueue.first as SelectRecordRequest;
        bool allowDelayedSelect = true;

        for (final dpc in dataProviderChanged) {
          if (selectRecord.soComponentData!.dataProvider == dpc.dataProvider) {
            allowDelayedSelect = false;
          }
        }

        if (request is FetchDataRequest &&
            request.dataProvider != selectRecord.dataProvider) {
          allowDelayedSelect = false;
        }

        if (allowDelayedSelect) {
          requestQueue.removeAt(0);

          if (selectRecord.soComponentData!.data != null &&
              selectRecord.soComponentData!.data!.records.length >
                  selectRecord.selectedRow) {
            selectRecord = selectRecord.soComponentData!.getSelectRecordRequest(
                context, selectRecord.selectedRow, selectRecord.fetch);

            sl<ApiCubit>().data(selectRecord);
          }
        }
      }

      dataProviderChanged.forEach((dpc) {
        SoComponentData cData = getComponentData(dpc.dataProvider);
        cData.updateDataProviderChanged(context, dpc, request);
      });

      if (request is SelectRecordRequest) {
        SoComponentData cData = getComponentData(request.dataProvider);
        cData.updateSelectedRow(context, request.selectedRow);
      }
    }

    for (final dpc in dataProviderChanged) {
      SoComponentData cData = getComponentData(dpc.dataProvider);
      cData.updateDataProviderChanged(context, dpc, request);
    }

    if (request is SelectRecordRequest) {
      SoComponentData cData = getComponentData(request.dataProvider);
      cData.updateSelectedRow(context, request.selectedRow);
    }
  }

  SoComponentData getComponentData(String dataProvider) {
    SoComponentData? data;

    if (componentData.length > 0) {
      try {
        data = componentData.firstWhere((d) => d.dataProvider == dataProvider);
      } catch (e) {
        print('No Component Data found. creating new one...');
      }
    }

    if (data == null && dataProvider.isNotEmpty) {
      data = SoComponentData(dataProvider: dataProvider, soDataScreen: this);
      componentData.add(data);
    }

    return data!;
  }

  void onAction(BuildContext context, String componentId,
      String? classNameEventSourceRef) async {
    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      PressButtonRequest pressButtonRequest = PressButtonRequest(
          classNameEventSourceRef: classNameEventSourceRef,
          clientId: AppStateProvider.of(context)!
              .appState
              .applicationMetaData!
              .clientId,
          componentId: componentId);

      sl<ApiCubit>().pressButton(pressButtonRequest);
    });
  }

  void onComponentValueChanged(
      BuildContext context, String componentId, dynamic value) {
    TextUtils.unfocusCurrentTextfield(context);

    Future.delayed(const Duration(milliseconds: 100), () {
      SetComponentValueRequest setComponentValueRequest =
          SetComponentValueRequest(
        componentId: componentId,
        value: value,
        clientId: AppStateProvider.of(context)!
            .appState
            .applicationMetaData!
            .clientId,
      );

      sl<ApiCubit>().setComponentValue(setComponentValueRequest);
    });
  }

  void requestNext(BuildContext context) {
    if (requestQueue.length > 0) {
      sl<ApiCubit>().data(requestQueue.first);
      requestQueue.removeAt(0);
    }
  }

  void goOffline(BuildContext context, ApiResponse response) async {
    final appState = AppStateProvider.of(context)!.appState;

    if (response.hasDataProviderChanged) {
      for (final dpc in response.getAllObjectsByType<DataproviderChanged>()) {
        getComponentData(dpc.dataProvider);
      }
    }

    if (response.hasDataBook) {
      for (final d in response.getAllObjectsByType<DataBook>()) {
        SoComponentData cData = getComponentData(d.dataProvider!);
        cData.updateData(context, d, response.request.reload);
      }
    }

    try {
      if (!response.hasError) {
        // WidgetsBinding.instance!
        //     .addPostFrameCallback((_) => showLinearProgressDialog(context));

        showLinearProgressDialog(context);

        String path = appState.baseDirectory + '/offlineDB.db';

        bool importSuccess =
            await sl<IOfflineDatabaseProvider>().openCreateDatabase(path);

        if (importSuccess) {
          await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
              .importComponents(context, componentData);
        }

        if ((sl<IOfflineDatabaseProvider>() as OfflineDatabase).responseError !=
            null) {
          // WidgetsBinding.instance!
          //     .addPostFrameCallback((_) => hideLinearProgressDialog(context));

          hideLinearProgressDialog(context);

          await showOfflineError(
              context,
              (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
                  .responseError);

          await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
              .cleanupDatabase();
        } else if (importSuccess) {
          // WidgetsBinding.instance!
          //     .addPostFrameCallback((_) => hideLinearProgressDialog(context));

          hideLinearProgressDialog(context);

          SharedPreferencesProvider.of(context)!.manager.isOffline = true;

          appState.isOffline = true;

          sl<ApiCubit>().navigation(NavigationRequest(
              componentId: '',
              clientId: appState.applicationMetaData!.clientId));
        }
      } else {
        WidgetsBinding.instance!
            .addPostFrameCallback((_) => hideLinearProgressDialog(context));
      }
    } catch (e) {
      try {
        WidgetsBinding.instance!
            .addPostFrameCallback((_) => hideLinearProgressDialog(context));

        SharedPreferencesProvider.of(context)!.manager.isOffline = false;
        AppState appState = AppStateProvider.of(context)!.appState;

        appState.isOffline = false;
        await (sl<IOfflineDatabaseProvider>() as OfflineDatabase)
            .cleanupDatabase();
      } catch (ee) {}

      rethrow;
    }
  }

  Future<void> showOfflineError(BuildContext context, Failure? failure) async {
    await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(failure?.title ?? ''),
            content: Text(failure?.message ?? ''),
            actions: <Widget>[
              ElevatedButton(
                child: Text(AppLocalizations.of(context)!.text('Close')),
                onPressed: () => Navigator.of(context).pop(),
              )
            ],
          );
        });
  }
}
