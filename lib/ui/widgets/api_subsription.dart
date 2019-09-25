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

          if (response.message == 'Invalid application!') {
            showGoToSettings(context, response.title, response.message);
          } else if (response.message == 'Application name is undefined!') {
            showGoToSettings(context, response.title, response.message);
          } else {
            showError(context, response.title, response.message);
          }
          return;
        } else if (p.response.content is BaseResponse && (p.response.content as BaseResponse).isSessionExpired) {
          BaseResponse response = (p.response.content as BaseResponse);
          showSessionExpired(context, response.title, "App will restart.");
          return;
        }
        switch (p.type) {
          case ApiType.performLogin:
            Future.delayed(const Duration(seconds: 1), () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: p.response.content.items, listMenuItemsInDrawer: true,)));
            });
            break;
          case ApiType.performStartup:
            globals.clientId = p.response.content.applicationMetaData.clientId;
            globals.language = p.response.content.language.langCode;
            globals.startupResponse = p.response.content;
            SharedPreferencesHelper().getAppVersion().then((val) async {
              if (val == null)
                SharedPreferencesHelper().setAppVersion(p.response.content.applicationMetaData.version);

              var _dir = (await getApplicationDocumentsDirectory()).path;

              globals.dir = _dir;
              
              if (val != p.response.content.applicationMetaData.version) {
                globals.hasToDownload = true;
                SharedPreferencesHelper().setAppVersion(p.response.content.applicationMetaData.version);
              }

              if (globals.hasToDownload)
                _download(context);

              _downloadAppStyle(context);

              if (!globals.hasToDownload) {
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
              }
            });
            break;
          case ApiType.performLogout:
            Navigator.of(context).pushReplacementNamed('/login');
            break;
          case ApiType.performDownload:
            if (globals.hasToDownload) {
              showProgress(context);
              // Future.delayed(const Duration(seconds: 5), () {
                SharedPreferencesHelper().getLoginData().then((onValue) {
                  if (onValue['username'] == null && onValue['password'] == null) {
                    if (globals.startupResponse.loginItem != null) {
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.of(context).pushReplacementNamed('/login');
                      });
                    } else {
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: globals.startupResponse.items, listMenuItemsInDrawer: true,)));
                      });
                    }
                  } else {
                    LoginBloc loginBloc = new LoginBloc();
                    StreamSubscription<FetchProcess> apiStreamSubscription;

                    apiStreamSubscription = apiSubscription(loginBloc.apiResult, context);
                    loginBloc.loginSink.add(new LoginViewModel.withPW(username: onValue['username'], password: onValue['password'], rememberMe: true));
                  }
                  hideProgress(context);
                });
              // });
            }

            globals.hasToDownload = false;
            break;
          case ApiType.performOpenScreen:
            Key componentID = new Key(p.response.content.componentId);
            Navigator.of(context).push(MaterialPageRoute(builder: (context) => 
              OpenScreenPage(
                changedComponents: p.response.content.changedComponents,
                data: p.response.content.data,
                metaData: p.response.content.metaData,
                componentId: componentID, 
                title: p.response.content.title)
            ));
            break;
          case ApiType.performCloseScreen:
            Navigator.of(context).pop();
            break;
          case ApiType.performPressButton:
            getIt.get<JVxScreen>().buttonCallback(p.response.content.updatedComponents);
            break;
          case ApiType.performApplicationStyle:
            if (p.response.content != null) {
              globals.applicationStyle = p.response.content;
              SharedPreferencesHelper().setApplicationStyle(
                  globals.applicationStyle.toJson());
            }
            break;
        }
      }
    }
  });
}

_download(BuildContext context) async {
  DownloadBloc downloadBloc1 = new DownloadBloc();
  DownloadBloc downloadBloc2 = new DownloadBloc();
  StreamSubscription apiStreamSubscription;

  downloadBloc1.downloadSink.add(new DownloadViewModel(clientId: globals.clientId, applicationImages: true, libraryImages: true, name: 'images'));
  apiStreamSubscription = apiSubscription(downloadBloc2.apiResult, context);
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