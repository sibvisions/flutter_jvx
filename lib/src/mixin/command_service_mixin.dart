import '../service/command/i_command_service.dart';
import '../service/service.dart';

///
/// Provides an [ICommandService] instance from get.it service
///
mixin CommandServiceMixin {
  final ICommandService commandService = services<ICommandService>();
}

mixin CommandServiceGetterMixin {
  ICommandService getCommandService() {
    return services<ICommandService>();
  }
}
