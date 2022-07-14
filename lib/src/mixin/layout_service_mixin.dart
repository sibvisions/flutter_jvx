import '../service/layout/i_layout_service.dart';
import '../service/service.dart';

///
///  Provides an [ILayoutService] instance from get.it service
///
mixin LayoutServiceMixin {
  final ILayoutService layoutService = services<ILayoutService>();
}

mixin LayoutServiceGetterMixin {
  ILayoutService getLayoutService() {
    return services<ILayoutService>();
  }
}
