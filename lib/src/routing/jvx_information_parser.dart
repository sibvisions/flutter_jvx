import 'package:flutter/cupertino.dart';
import 'package:flutter_jvx/src/routing/jvx_route_path.dart';

class JVxRouteInformationParser extends RouteInformationParser<JVxRoutePath> {


  @override
  Future<JVxRoutePath> parseRouteInformation(RouteInformation routeInformation) async {
    return JVxRoutePath.login();
  }

}