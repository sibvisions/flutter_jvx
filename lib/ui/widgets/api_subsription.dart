import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/logic/bloc/application_style_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/download_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/login_bloc.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/application_style_view_model.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/download_view_model.dart';
import 'package:jvx_mobile_v3/logic/viewmodel/login_view_model.dart';
import 'package:jvx_mobile_v3/main.dart';
import 'package:jvx_mobile_v3/model/application_style/application_style_resp.dart';
import 'package:jvx_mobile_v3/model/base_resp.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/page/open_screen_page.dart';
import 'package:jvx_mobile_v3/ui/page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jvx_mobile_v3/ui/jvx_screen.dart';

apiSubscription(Stream<FetchProcess> apiResult, BuildContext context) {  
  apiResult.listen((FetchProcess p) {
    if (p.loading) {
      showProgress(context);
    } else {
      hideProgress(context);
      if (p.response.success == false) {
        fetchApiResult(context, p.response);
      } else {
        if (p.response.content is BaseResponse && (p.response.content as BaseResponse).isError) {
          BaseResponse response = (p.response.content as BaseResponse);
          showTextInputDialog(context, response.title, response.message, response.details, null, null);
          return;
        }
        switch (p.type) {
          case ApiType.performLogin:
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: p.response.content.items, listMenuItemsInDrawer: true,)));
            });
            break;
          case ApiType.performStartup:
            globals.language = p.response.content.language.langCode;
              SharedPreferencesHelper().getAppVersion().then((val) async {
                if (val == null)
                  SharedPreferencesHelper().setAppVersion(p.response.content.applicationMetaData.version);

                  var _dir = (await getApplicationDocumentsDirectory()).path;

                  globals.dir = _dir;

                _downloadAppStyle(context);
                
                if (val != p.response.content.applicationMetaData.version) {
                  SharedPreferencesHelper().setAppVersion(p.response.content.applicationMetaData.version);
                  _download(context);
                }
              });
              SharedPreferencesHelper().getLoginData().then((onValue) {
                if (onValue['username'] == null && onValue['password'] == null) {
                  if (p.response.content.loginItem != null) {
                    Future.delayed(const Duration(seconds: 1), () {
                      Navigator.of(context).pushReplacementNamed('/login');
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
            Navigator.of(context).pushReplacementNamed('/login');
            break;
          case ApiType.performDownload:
            Translations.load(new Locale(globals.language));
            break;
          case ApiType.performOpenScreen:
            Key componentID = new Key(p.response.content.componentId);
            Navigator.of(context).push(MaterialPageRoute(builder:  (context) => 
              OpenScreenPage(changedComponents: p.response.content.changedComponents, componentId: componentID,
            )));
            break;
          case ApiType.performCloseScreen:
            break;
          case ApiType.performPressButton:
            getIt.get<JVxScreen>().buttonCallback(p.response.content.updatedComponents);      
            break;
          case ApiType.performApplicationStyle:
            globals.applicationStyle = p.response.content;
            print("LOGIN BACKGROUND: " + globals.applicationStyle.loginBackground);
            SharedPreferencesHelper().setApplicationStyle(globals.applicationStyle.toJson());
            break;
        }
      }
    }
  });
}



_download(BuildContext context) {
  DownloadBloc downloadBloc1 = new DownloadBloc();
  DownloadBloc downloadBloc2 = new DownloadBloc();

  downloadBloc1.downloadSink.add(new DownloadViewModel(clientId: globals.clientId, applicationImages: true, libraryImages: true, name: 'images'));
  downloadBloc2.downloadSink.add(new DownloadViewModel(clientId: globals.clientId, applicationImages: false, libraryImages: false, name: 'translation'));
}

_downloadAppStyle(BuildContext context) {
  ApplicationStyleBloc applicationStyleBloc = new ApplicationStyleBloc();
  StreamSubscription apiStreamSubscription;

  SharedPreferencesHelper().getApplicationStyle().then((val) {
    if (val != null) {
      globals.applicationStyle = ApplicationStyleResponse.fromJson(val);
    } else {
      apiStreamSubscription = apiSubscription(applicationStyleBloc.apiResult, context);
      applicationStyleBloc.applicationStyleSink.add(new ApplicationStyleViewModel(clientId: globals.clientId, name: 'applicationStyle', contentMode: 'json'));
    }
  });
}