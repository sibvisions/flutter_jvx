import '../src/service/api/i_api_service.dart';
import '../src/service/command/i_command_service.dart';
import '../src/service/config/i_config_service.dart';
import '../src/service/data/i_data_service.dart';
import '../src/service/layout/i_layout_service.dart';
import '../src/service/service.dart';
import '../src/service/storage/i_storage_service.dart';
import '../src/service/ui/i_ui_service.dart';

export '../src/service/api/i_api_service.dart';
export '../src/service/api/impl/default/api_service.dart';
export '../src/service/command/i_command_service.dart';
export '../src/service/command/impl/command_service.dart';
export '../src/service/config/i_config_service.dart';
export '../src/service/config/impl/config_service.dart';
export '../src/service/data/i_data_service.dart';
export '../src/service/data/impl/data_service.dart';
export '../src/service/layout/i_layout_service.dart';
export '../src/service/layout/impl/layout_service.dart';
export '../src/service/storage/i_storage_service.dart';
export '../src/service/storage/impl/default/storage_service.dart';
export '../src/service/ui/i_ui_service.dart';
export '../src/service/ui/impl/ui_service.dart';

///
///  Provides an [IConfigService] instance from get.it service
///
mixin ConfigServiceMixin {
  IConfigService getConfigService() {
    return services<IConfigService>();
  }
}

///
///  Provides an [IApiService] instance from get.it service
///
mixin ApiServiceMixin {
  IApiService getApiService() {
    return services<IApiService>();
  }
}

///
/// Provides an [ICommandService] instance from get.it service
///
mixin CommandServiceMixin {
  ICommandService getCommandService() {
    return services<ICommandService>();
  }
}

///
///  Provides an [IConfigService] instance from get.it service
///
mixin UiServiceMixin {
  IUiService getUiService() {
    return services<IUiService>();
  }
}

///
/// Provides an [IDataService] instance from get.it service
///
mixin DataServiceMixin {
  IDataService getDataService() {
    return services<IDataService>();
  }
}

///
///  Provides an [ILayoutService] instance from get.it service
///
mixin LayoutServiceMixin {
  ILayoutService getLayoutService() {
    return services<ILayoutService>();
  }
}

///
///  Provides an [IStorageService] instance from get.it service
///
mixin StorageServiceMixin {
  IStorageService getStorageService() {
    return services<IStorageService>();
  }
}
