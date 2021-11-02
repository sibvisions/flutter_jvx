import 'package:flutter_jvx/src/services/api/i_controller.dart';
import 'package:flutter_jvx/src/services/api/i_repository.dart';
import 'package:flutter_jvx/src/services/service.dart';

mixin ApiServiceMixin{
  final IRepository apiRepository = services<IRepository>();
  final IController apiController = services<IController>();
}