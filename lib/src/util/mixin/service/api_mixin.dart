import 'package:flutter_jvx/src/services/isolate/api_isolate_service.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin ApiMixin{
  final ApiIsolateService apiService = services<ApiIsolateService>();
}