import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/error_handler.dart';
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

enum StartupValidationType { username, password }

class StartupPage extends StatefulWidget {
  StartupPage({Key key}) : super(key: key);

  _StartupPageState createState() => _StartupPageState();
}

class _StartupPageState extends State<StartupPage> {
  bool errorMsgShown = false;

  Widget newStartupBuilder() {
    return errorHandlerListener(
      BlocBuilder<ApiBloc, Response>(
        builder: (context, state) {
          startupHandler(state);

          return Scaffold(
            body: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Center(
                  child: Image.asset(
                    'assets/images/sib_visions.jpg',
                    width: (MediaQuery.of(context).size.width - 50),
                  ),
                ),
                Text('Loading...'),
              ],
            ),
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.wait([Config.loadFile(), loadSharedPrefs()]).then((val) {
      if (val[0] != null && val[0].debug != null && val[0].debug) {
        if (val[0].appName != null && val[0].appName.isNotEmpty) {
          globals.appName = val[0].appName;
        } else {
          showError(context, 'Error in Config', 'Please enter a valid application name in conf.json and restart the app.');
          return;
        }

        if (val[0].baseUrl != null && val[0].baseUrl.isNotEmpty) {
          if (val[0].baseUrl.endsWith('/')) {
            showError(context, 'Error in Config', 'Please delete the "/" at the end of your base url in the conf.json file and restart the app.');
            return;
          } else {
            globals.baseUrl = val[0].baseUrl;
          }
        } else {
          showError(context, 'Error in Config', 'Please enter a valid base url in conf.json and restart the app.');
        }
        globals.debug = val[0].debug;
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
          requestType: RequestType.STARTUP);

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

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return newStartupBuilder();
  }

  void startupHandler(Response state) {
    if (state != null &&
        !state.loading &&
        state.requestType == RequestType.STARTUP &&
        state.applicationMetaData != null &&
        state.language != null &&
        (!state.error || state.error == null)) {
      String appVersion;
      SharedPreferencesHelper().getAppVersion().then((val) {
        appVersion = val;

        ApplicationMetaData applicationMetaData = state.applicationMetaData;

        if (appVersion != applicationMetaData.version) {
          SharedPreferencesHelper()
              .setAppVersion(applicationMetaData.version);
          _download();
        }

        ApplicationStyle applicationStyle = ApplicationStyle(
            clientId: applicationMetaData.clientId,
            requestType: RequestType.APP_STYLE,
            name: 'applicationStyle',
            contentMode: 'json');

        BlocProvider.of<ApiBloc>(context).dispatch(applicationStyle);

        Menu menu = state.menu;

        Future.delayed(Duration.zero, () {
          if (menu == null) {
            Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => LoginPage()));
          } else {
            Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (_) => MenuPage(
                      menuItems: menu.items,
                    )));
          }
        });
      });
    }
  }
}
