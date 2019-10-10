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
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/page/open_screen_page.dart';
import '../page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:path_provider/path_provider.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';

apiSubscription(Stream<FetchProcess> apiResult, BuildContext context) {
  apiResult.listen((FetchProcess p) {
    if (p.loading) {
      if (p.type == ApiType.performDownload) {
        showProgress(context, 'Downloading Resources');
      } else {
        showProgress(context);
      }
    } else {
      hideProgress(context);
      if (p.response.success == false) {
        fetchApiResult(context, p.response);
      } else {
        if (p.response.content is BaseResponse &&
            (p.response.content as BaseResponse).isError) {
          BaseResponse response = (p.response.content as BaseResponse);

          if (response.message == 'Invalid application!') {
            showGoToSettings(context, response.title, response.message);
          } else if (response.message == 'Application name is undefined!') {
            showGoToSettings(context, response.title, response.message);
          } else {
            showError(context, response.title, response.message);
          }
          return;
        } else if (p.response.content is BaseResponse &&
            (p.response.content as BaseResponse).isSessionExpired) {
          BaseResponse response = (p.response.content as BaseResponse);
          showSessionExpired(context, response.title, "App will restart.");
          return;
        }
        switch (p.type) {
          case ApiType.performLogin:
            globals.items = p.response.content.items;
            Navigator.pushReplacement(context, MaterialPageRoute(
                builder: (context) => MenuPage(
                      menuItems: p.response.content.items,
                      listMenuItemsInDrawer: true,
                    )));
            break;
          case ApiType.performStartup:
            globals.clientId = p.response.content.applicationMetaData.clientId;
            globals.language = p.response.content.language.langCode;
            globals.startupResponse = p.response.content;
            SharedPreferencesHelper().getAppVersion().then((val) async {
              if (val == null)
                SharedPreferencesHelper().setAppVersion(
                    p.response.content.applicationMetaData.version);

              var _dir = (await getApplicationDocumentsDirectory()).path;

              globals.dir = _dir;

              if (val != p.response.content.applicationMetaData.version) {
                globals.hasToDownload = true;
                SharedPreferencesHelper().setAppVersion(
                    p.response.content.applicationMetaData.version);
              }

              // Just for debug reasons
              globals.hasToDownload = true;

              if (globals.hasToDownload) _download(context);

              _downloadAppStyle(context);

              if (!globals.hasToDownload) {
                Translations.load(Locale(globals.language));
                if (p.response.content.loginItem != null) {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => LoginPage()
                    ));
                  });
                  return;
                }

                SharedPreferencesHelper().getLoginData().then((onValue) {
                  if (onValue['username'] == null || onValue['username'] == 'null' ||
                      onValue['password'] == null || onValue['password'] == 'null' ||
                      onValue['authKey'] != null || onValue['authKey'] != 'null'
                  ) {
                    Future.delayed(const Duration(seconds: 1), () {
                      globals.items = p.response.content.items;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MenuPage(
                                menuItems: p.response.content.items,
                                listMenuItemsInDrawer: true,
                              )));
                    });
                  } else {
                    globals.username = onValue['username'];

                    LoginBloc loginBloc = new LoginBloc();
                    StreamSubscription<FetchProcess> apiStreamSubscription;

                    apiStreamSubscription =
                        apiSubscription(loginBloc.apiResult, context);
                    loginBloc.loginSink.add(new LoginViewModel.withPW(
                        username: onValue['username'],
                        password: onValue['password'],
                        rememberMe: true));
                  }
                });
              }
            });
            break;
          case ApiType.performLogout:
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
            break;
          case ApiType.performDownload:
            if (globals.hasToDownload) {
              Translations.load(Locale(globals.language));
              showProgress(context);
              if (globals.startupResponse.loginItem != null) {
                  Future.delayed(const Duration(seconds: 1), () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) => LoginPage()
                    ));
                  });
                  return;
                }

                SharedPreferencesHelper().getLoginData().then((onValue) {
                  if (onValue['username'] == null || onValue['username'] == 'null' ||
                      onValue['password'] == null || onValue['password'] == 'null' ||
                      onValue['authKey'] != null || onValue['authKey'] != 'null'
                  ) {
                    Future.delayed(const Duration(seconds: 1), () {
                      globals.items = globals.startupResponse.items;
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (context) => MenuPage(
                                menuItems: globals.startupResponse.items,
                                listMenuItemsInDrawer: true,
                              )));
                    });
                  } else {
                    globals.username = onValue['username'];

                    LoginBloc loginBloc = new LoginBloc();
                    StreamSubscription<FetchProcess> apiStreamSubscription;

                    apiStreamSubscription =
                        apiSubscription(loginBloc.apiResult, context);
                    loginBloc.loginSink.add(new LoginViewModel.withPW(
                        username: onValue['username'],
                        password: onValue['password'],
                        rememberMe: true));
                  }
                  hideProgress(context);
                });
            }

            globals.hasToDownload = false;
            break;
          case ApiType.performOpenScreen:
            Key componentID = new Key(p.response.content.componentId);
            /*
            if (globals.changeScreen != null) {
              globals.changeScreen = null;
              getIt.get<JVxScreen>().componentId = componentID;
              getIt.get<JVxScreen>().context = context;

              getIt.get<JVxScreen>().components = <String, JVxComponent>{};
              getIt.get<JVxScreen>().data = p.response.content.data;
              getIt.get<JVxScreen>().metaData = p.response.content.metaData;
              getIt.get<JVxScreen>().title = p.response.content.title;
              getIt.get<JVxScreen>().updateComponents(p.response.content.changedComponents);
              getIt.get<JVxScreen>().buttonCallback(null);
            } else {
              */
              print('HELLO OPENSCREEN');
              Navigator.of(context).push(MaterialPageRoute(
                  builder: (context) => new OpenScreenPage(
                      changedComponents: p.response.content.changedComponents,
                      data: p.response.content._data,
                      metaData: p.response.content.metaData,
                      componentId: componentID,
                      title: p.response.content.title,
                      items: globals.items,)));
            // }
            break;
          case ApiType.performCloseScreen:
            print('HELLO CLOSESCREEN');
            Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: globals.items, listMenuItemsInDrawer: false,)));
            break;
          case ApiType.performPressButton:
            getIt
                .get<JVxScreen>("screen")
                .buttonCallback(p.response.content.updatedComponents);
            break;
          case ApiType.performApplicationStyle:
            if (p.response.content != null) {
              globals.applicationStyle = p.response.content;
              SharedPreferencesHelper()
                  .setApplicationStyle(globals.applicationStyle.toJson());
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

  downloadBloc1.downloadSink.add(new DownloadViewModel(
      clientId: globals.clientId,
      applicationImages: true,
      libraryImages: true,
      name: 'images'));
  apiStreamSubscription = apiSubscription(downloadBloc2.apiResult, context);
  downloadBloc2.downloadSink.add(new DownloadViewModel(
      clientId: globals.clientId,
      applicationImages: false,
      libraryImages: false,
      name: 'translation'));
}

_downloadAppStyle(BuildContext context) {
  ApplicationStyleBloc applicationStyleBloc = new ApplicationStyleBloc();
  StreamSubscription apiStreamSubscription;

  SharedPreferencesHelper().getApplicationStyle().then((val) {
    if (val != null) {
      globals.applicationStyle = ApplicationStyleResponse.fromJson(val);
    } else {
      apiStreamSubscription =
          apiSubscription(applicationStyleBloc.apiResult, context);
      applicationStyleBloc.applicationStyleSink.add(
          new ApplicationStyleViewModel(
              clientId: globals.clientId,
              name: 'applicationStyle',
              contentMode: 'json'));
    }
  });
}
