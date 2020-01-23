import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
import 'package:jvx_mobile_v3/logic/bloc/theme_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/loading.dart';
import 'package:jvx_mobile_v3/model/api/request/login.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/api/response/application_meta_data.dart';
import 'package:jvx_mobile_v3/model/api/request/application_style.dart';
import 'package:jvx_mobile_v3/model/api/request/download.dart';
import 'package:jvx_mobile_v3/model/api/response/login_item.dart';
import 'package:jvx_mobile_v3/model/api/response/menu.dart';
import 'package:jvx_mobile_v3/model/api/request/startup.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/config.dart';
import 'package:jvx_mobile_v3/utils/shared_preferences_helper.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;
import 'package:jvx_mobile_v3/utils/translations.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';
import 'package:uuid/uuid.dart';

enum StartupValidationType { username, password }

class StartupPage extends StatefulWidget {
  bool loadConf;

  StartupPage(this.loadConf, {Key key}) : super(key: key);

  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool errorMsgShown = false;

  Widget newStartupBuilder() {
    return errorHandlerListener(
      BlocListener<ApiBloc, Response>(
        listener: (context, state) {
          print('Startup Page Request Type: ${state.requestType}');
          _startupHandler(state);
          _navigationHandler(state);
          _loginHandler(state);
        },
        child: Scaffold(
          body: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Center(
                child: Image.asset(
                  'assets/images/sib_visions.jpg',
                  width: (MediaQuery.of(context).size.width - 50),
                ),
              ),
              CircularProgressIndicator(),
              Text('Loading...')
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.wait([
      Config.loadFile(),
      loadSharedPrefs(),
    ]).then((val) async {
      print('HELLO ${widget.loadConf}');
      if (widget.loadConf &&
          val[0] != null &&
          val[0].debug != null &&
          val[0].debug) {
        print("******************************************************");
        print("Config loaded: ${val[0].debug}");
        print("AppName: ${val[0].appName}");
        print("Hostname: ${val[0].baseUrl}");
        print("Username: ${val[0].username}");
        print("Password: ${val[0].password}");
        print("AppMode: ${val[0].appMode}");
        print("******************************************************");

        if (val[0].appName != null && val[0].appName.isNotEmpty) {
          globals.appName = val[0].appName;
          SharedPreferencesHelper().setData(val[0].appName, null, null, null);
        } else {
          showError(context, 'Error in Config',
              'Please enter a valid application name in conf.json and restart the app.');
          return;
        }

        if (val[0].baseUrl != null && val[0].baseUrl.isNotEmpty) {
          if (val[0].baseUrl.endsWith('/')) {
            showError(context, 'Error in Config',
                'Please delete the "/" at the end of your base url in the conf.json file and restart the app.');
            return;
          } else {
            globals.baseUrl = val[0].baseUrl;
            SharedPreferencesHelper().setData(null, val[0].baseUrl, null, null);
          }
        } else {
          showError(context, 'Error in Config',
              'Please enter a valid base url in conf.json and restart the app.');
        }
        globals.debug = val[0].debug;

        if (val[0].username != null &&
            val[0].username.isNotEmpty &&
            (globals.username == null || globals.username.isEmpty)) {
          globals.username = val[0].username;
        }

        if (val[0].password != null &&
            val[0].password.isNotEmpty &&
            (globals.password == null || globals.password.isEmpty)) {
          globals.password = val[0].password;
        }

        if (val[0].appMode != null && val[0].appMode.isNotEmpty) {
          globals.appMode = val[0].appMode;
        }
      } else {
        //BlocProvider.of<ApiBloc>(context).dispatch(Loading());
      }

      if (globals.appName == null || globals.baseUrl == null) {
        Navigator.pushReplacementNamed(context, '/settings');
        return;
      }

      Startup request = Startup(
          layoutMode: 'generic',
          applicationName: globals.appName,
          screenHeight: MediaQuery.of(context).size.height.toInt(),
          screenWidth: MediaQuery.of(context).size.width.toInt(),
          appMode: globals.appMode.isNotEmpty ? globals.appMode : 'preview',
          readAheadLimit: 100,
          requestType: RequestType.STARTUP,
          deviceId: await _getDeviceId());

      BlocProvider.of<ApiBloc>(context).dispatch(request);
    });
  }

  Future<Null> loadSharedPrefs() async {
    globals.translation = await SharedPreferencesHelper().getTranslation();
    await SharedPreferencesHelper().getData().then((prefData) {
      if (prefData['appName'] == 'null' ||
          prefData['appName'] == null ||
          prefData['appName'].isEmpty) {
      } else {
        globals.appName = prefData['appName'];
      }
      if (prefData['baseUrl'] == 'null' ||
          prefData['baseUrl'] == null ||
          prefData['baseUrl'].isEmpty) {
      } else {
        globals.baseUrl = prefData['baseUrl'];
      }
      if (prefData['language'] == 'null' ||
          prefData['language'] == null ||
          prefData['language'].isEmpty) {
      } else {
        globals.language = prefData['language'];
      }

      if (prefData['picSize'] != null) {
        globals.uploadPicWidth = prefData['picSize'];
      }
    });
  }

  _download() {
    Download translation = Download(
        applicationImages: false,
        libraryImages: false,
        clientId: globals.clientId,
        name: 'translation',
        requestType: RequestType.DOWNLOAD_TRANSLATION);

    BlocProvider.of<ApiBloc>(context).dispatch(translation);

    Download images = Download(
        applicationImages: true,
        libraryImages: true,
        clientId: globals.clientId,
        name: 'images',
        requestType: RequestType.DOWNLOAD_IMAGES);

    BlocProvider.of<ApiBloc>(context).dispatch(images);
  }

  Future<String> _getDeviceId() async {
    String deviceId = await SharedPreferencesHelper().getDeviceId();
    if (deviceId != null) {
      return deviceId;
    }
    String generatedID = Uuid().v1();
    SharedPreferencesHelper().setDeviceId(generatedID);
    return generatedID;
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return newStartupBuilder();
  }

  void _loginHandler(Response state) {
    if (state != null &&
        state.requestType == RequestType.LOGIN &&
        state.menu != null) {
      if (state.userData != null) {
        if (state.userData.userName != null) {
          globals.username = state.userData.userName;
        }

        if (state.userData.displayName != null) {
          globals.displayName = state.userData.displayName;
        }

        if (state.userData.profileImage != null)
          globals.profileImage = state.userData.profileImage;
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(
          builder: (_) => MenuPage(
                menuItems: state.menu.items,
              )));
    }
  }

  void _navigationHandler(Response state) {
    if (state != null && state.requestType == RequestType.APP_STYLE) {
      if (state.applicationStyle != null &&
          state.applicationStyle.themeColor != null) {
        Map<int, Color> color = {
          50: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .1),
          100: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .2),
          200: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .3),
          300: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .4),
          400: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .5),
          500: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .6),
          600: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .7),
          700: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .8),
          800: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              .9),
          900: Color.fromRGBO(
              state.applicationStyle.themeColor.red,
              state.applicationStyle.themeColor.green,
              state.applicationStyle.themeColor.blue,
              1),
        };

        MaterialColor colorCustom =
            MaterialColor(state.applicationStyle.themeColor.value, color);

        UIData.ui_kit_color_2 = colorCustom;

        BlocProvider.of<ThemeBloc>(context).dispatch(ThemeData(
          primaryColor: colorCustom,
          primarySwatch: colorCustom,
          brightness: Brightness.light,
          fontFamily: 'Raleway'
        ));
      }

      Menu menu = state.menu;

      if (state.menu == null &&
          globals.username.isNotEmpty &&
          globals.password.isNotEmpty) {
        Login login = Login(
            action: 'Anmelden',
            clientId: globals.clientId,
            createAuthKey: false,
            username: globals.username,
            password: globals.password,
            requestType: RequestType.LOGIN);

        BlocProvider.of<ApiBloc>(context).dispatch(login);
      }

      if (menu == null) {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (_) => LoginPage()));
      } else {
        if (state.userData != null) {
          if (state.userData.userName != null) {
            globals.username = state.userData.userName;
          }

          if (state.userData.displayName != null) {
            globals.displayName = state.userData.displayName;
          }

          if (state.userData.profileImage != null)
            globals.profileImage = state.userData.profileImage;
        }
        Navigator.of(context).pushReplacement(MaterialPageRoute(
            builder: (_) => MenuPage(
                  menuItems: menu.items,
                )));
      }
    }
  }

  void _startupHandler(Response state) {
    if (state != null &&
        state.requestType == RequestType.STARTUP &&
        state.applicationMetaData != null &&
        state.language != null) {
      String appVersion;
      SharedPreferencesHelper().getAppVersion().then((val) async {
        if (state.userData != null) {
          if (state.userData.userName != null) {
            globals.username = state.userData.userName;
          }
          if (state.userData.displayName != null) {
            globals.displayName = state.userData.displayName;
          }

          if (state.userData.profileImage != null)
            globals.profileImage = state.userData.profileImage;
        }
        appVersion = val;

        ApplicationMetaData applicationMetaData = state.applicationMetaData;

        print('DOWNLOAD: ${appVersion != applicationMetaData.version}');

        bool shouddl = await Translations.shouldDownload();

        if (appVersion != applicationMetaData.version || shouddl) {
          SharedPreferencesHelper().setAppVersion(applicationMetaData.version);
          _download();
        }

        ApplicationStyle applicationStyle = ApplicationStyle(
            clientId: applicationMetaData.clientId,
            requestType: RequestType.APP_STYLE,
            name: 'applicationStyle',
            contentMode: 'json');

        BlocProvider.of<ApiBloc>(context).dispatch(applicationStyle);
      });
    }
  }
}
