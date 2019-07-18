import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/model/fetch_process.dart';
import 'package:jvx_mobile_v3/ui/page/login_page.dart';
import 'package:jvx_mobile_v3/ui/page/menu_page.dart';
import 'package:jvx_mobile_v3/ui/widgets/common_dialogs.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

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
            // showSuccess(context, UIData.success, FontAwesomeIcons.check);
            if (p.response.content.loginItem != null) {
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
              });
            } else {
              Future.delayed(const Duration(seconds: 1), () {
                Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => MenuPage(menuItems: p.response.content.items, listMenuItemsInDrawer: true,)));
              });
            }
            break;
        }
      }
    }
  });
}