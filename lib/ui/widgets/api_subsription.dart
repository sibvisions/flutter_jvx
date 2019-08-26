import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/download_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/login_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/download_view_model.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/login_view_model.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/page/open_screen_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:path_provider/path_provider.dart';

apiSubscription(Stream<FetchProcess> apiResult, BuildContext context) {  
  apiResult.listen((FetchProcess p) {
    if (p.loading) {
      showProgress(context);
    } else {
      hideProgress(context);
      if (p.response.success == false) {
        fetchApiResult(context, p.response);
      } else {
        switch (p.type) {
          case ApiType.performLogin:
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: p.response.content.items, listMenuItemsInDrawer: true,)));
            });
            break;
          case ApiType.performStartup:
            SharedPreferencesHelper().getAppVersion().then((val) async {
              if (val == null)
                SharedPreferencesHelper().setAppVersion(p.response.content.applicationMetaData.version);

                var _dir = (await getApplicationDocumentsDirectory()).path;

                globals.dir = _dir;

              if (val != p.response.content.applicationMetaData.version)
                _download(context);
            });
            SharedPreferencesHelper().getLoginData().then((onValue) {
              if (onValue['username'] == null && onValue['password'] == null) {
                if (p.response.content.loginItem != null) {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
                  });
                } else {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: p.response.content.items, listMenuItemsInDrawer: true,)));
                  });
                }
              } else {
                LoginBloc loginBloc = new LoginBloc();
                StreamSubscription<FetchProcess> apiStreamSubscription;

                apiStreamSubscription = apiSubscription(loginBloc.apiResult, context);
                loginBloc.loginSink.add(new LoginViewModel.withPW(username: onValue['username'], password: onValue['password'], rememberMe: true));
              }
            });
            break;
          case ApiType.performLogout:
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
            break;
          case ApiType.performDownload:
            break;
          case ApiType.performOpenScreen:
            Key componentID = new Key(p.response.content.componentId);
            Navigator.of(context).push(MaterialPageRoute(builder:  (context) => OpenScreenPage(changedComponents: p.response.content.changedComponents, componentId: componentID,)));
            break;
          case ApiType.performCloseScreen:
            Navigator.of(context).pop();
            break;
        }
      }
    }
  });
}



_download(BuildContext context) {
  DownloadBloc downloadBloc1 = new DownloadBloc();
  DownloadBloc downloadBloc2 = new DownloadBloc();
  // StreamSubscription<FetchProcess> apiStreamSubscription1;
  // StreamSubscription<FetchProcess> apiStreamSubscription2;

  // apiStreamSubscription1 = apiSubscription(downloadBloc1.apiResult, context);
  // apiStreamSubscription2 = apiSubscription(downloadBloc2.apiResult, context);
  downloadBloc1.downloadSink.add(new DownloadViewModel(clientId: globals.clientId, applicationImages: true, libraryImages: true, name: 'images'));
  downloadBloc2.downloadSink.add(new DownloadViewModel(clientId: globals.clientId, applicationImages: false, libraryImages: false, name: 'translation'));
}