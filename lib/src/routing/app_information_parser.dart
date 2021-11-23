
import 'package:flutter/material.dart';

import 'app_route_path.dart';

class AppInformationParser extends RouteInformationParser<AppRoutePath> {


  @override
  Future<AppRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    return AppRoutePath.login();
  }

}