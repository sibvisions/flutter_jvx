import 'package:jvx_mobile_v3/services/abstract/i_login_service.dart';
import 'package:jvx_mobile_v3/services/abstract/i_startup_service.dart';
import 'package:jvx_mobile_v3/services/mock/mock_login_service.dart';
import 'package:jvx_mobile_v3/services/mock/mock_startup_service.dart';
import 'package:jvx_mobile_v3/services/real/real_login_service.dart';
import 'package:jvx_mobile_v3/services/real/real_startup_service.dart';
import 'package:jvx_mobile_v3/services/restClient.dart';

enum Flavor { MOCK, PRO }

class Injector {
  static final Injector _singelton = new Injector._internal();
  static Flavor _flavor;

  static void configure(Flavor flavor) async {
    _flavor = flavor;
  }

  factory Injector() => _singelton;

  Injector._internal();

  ILoginService get loginService {
    switch (_flavor) {
      case Flavor.MOCK:
        return MockLoginService();
      default:
        return LoginService(new RestClient());
    }
  }
  
  IStartupService get startupService {
    switch (_flavor) {
      case Flavor.MOCK:
        return MockStartupService();
      default:
        return StartupService(new RestClient());
    }
  }
}