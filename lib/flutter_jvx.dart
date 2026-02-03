/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

/// FlutterJVx: Bridge between Flutter and [JVx](https://sourceforge.net/projects/jvx/).
library flutter_jvx;

export 'package:beamer/beamer.dart';
export 'package:dio/dio.dart';
export 'package:flutter_debug_overlay/flutter_debug_overlay.dart' hide LogEvent;
export 'package:flutter_tts/flutter_tts.dart';
export 'package:latlong2/latlong.dart';
export 'package:logger/logger.dart';
export 'package:speech_to_text/speech_recognition_event.dart';
export 'package:speech_to_text/speech_to_text.dart';

export 'src/commands.dart';
export 'src/components.dart';
// Config
export 'src/config/api/api_route.dart';
export 'src/config/app_config.dart';
export 'src/config/log/log_config.dart';
export 'src/config/log/log_level_config.dart';
export 'src/config/offline_config.dart';
export 'src/config/predefined_server_config.dart';
export 'src/config/server_config.dart';
export 'src/config/ui_config.dart';
export 'src/config/version_config.dart';
// Custom
export 'src/custom/app_manager.dart';
export 'src/custom/custom_component.dart';
export 'src/custom/custom_header.dart';
export 'src/custom/custom_menu_item.dart';
export 'src/custom/custom_screen.dart';
export 'src/flutter_ui.dart';
// Mask
export 'src/mask/jvx_overlay.dart';
export 'src/mask/login/default/arc_clipper.dart';
export 'src/mask/login/default/default_login.dart';
export 'src/mask/login/login.dart';
export 'src/mask/login/login_page.dart';
export 'src/mask/login/modern/modern_login.dart';
export 'src/mask/login/login_handler.dart';
export 'src/mask/menu/grid/grid_menu.dart';
export 'src/mask/menu/grid/widget/grid_menu_group.dart';
export 'src/mask/menu/grid/widget/grid_menu_header.dart';
export 'src/mask/menu/grid/widget/grid_menu_item.dart';
export 'src/mask/menu/list/list_menu.dart';
export 'src/mask/menu/list/widget/list_menu_group.dart';
export 'src/mask/menu/list/widget/list_menu_item.dart';
export 'src/mask/menu/menu.dart';
export 'src/mask/menu/tab/tab_menu.dart';
export 'src/mask/splash/jvx_exit_splash.dart';
export 'src/mask/splash/jvx_splash.dart';
export 'src/mask/state/app_style.dart';
export 'src/mask/state/loading_bar.dart';
export 'src/model/api_interaction.dart';
// Model
export 'src/model/command/base_command.dart';
export 'src/model/component/fl_component_model.dart';
export 'src/model/config/application_parameters.dart';
export 'src/model/config/translation/i18n.dart';
export 'src/model/config/user/user_info.dart';
// Data
export 'src/model/data/column_definition.dart';
export 'src/model/data/data_book.dart';
export 'src/model/data/filter_condition.dart';
export 'src/model/data/subscriptions/data_chunk.dart';
export 'src/model/data/subscriptions/data_record.dart';
export 'src/model/data/subscriptions/data_subscription.dart';
export 'src/model/menu/menu_group_model.dart';
export 'src/model/menu/menu_item_model.dart';
export 'src/model/menu/menu_model.dart';
export 'src/model/request/api_request.dart';
export 'src/model/request/filter.dart';
export 'src/model/response/api_response.dart';
export 'src/model/response/application_meta_data_response.dart';
export 'src/model/response/application_parameters_response.dart';
export 'src/model/response/application_settings_response.dart';
export 'src/model/response/authentication_data_response.dart';
export 'src/model/response/bad_client_response.dart';
export 'src/model/response/close_content_response.dart';
export 'src/model/response/close_frame_response.dart';
export 'src/model/response/close_screen_response.dart';
export 'src/model/response/content_response.dart';
export 'src/model/response/dal_data_provider_changed_response.dart';
export 'src/model/response/dal_fetch_response.dart';
export 'src/model/response/dal_meta_data_response.dart';
export 'src/model/response/device_status_response.dart';
export 'src/model/response/download_action_response.dart';
export 'src/model/response/download_images_response.dart';
export 'src/model/response/download_response.dart';
export 'src/model/response/download_style_response.dart';
export 'src/model/response/download_translation_response.dart';
export 'src/model/response/generic_screen_view_response.dart';
export 'src/model/response/language_response.dart';
export 'src/model/response/login_view_response.dart';
export 'src/model/response/menu_view_response.dart';
export 'src/model/response/show_document_response.dart';
export 'src/model/response/upload_action_response.dart';
export 'src/model/response/user_data_response.dart';
export 'src/routing/locations/main_location.dart';
// Services
export 'src/service/api/i_api_service.dart';
export 'src/service/api/impl/default/api_service.dart';
export 'src/service/api/shared/api_object_property.dart';
export 'src/service/api/shared/i_repository.dart';
export 'src/service/api/shared/repository/jvx_web_socket.dart';
export 'src/service/apps/app.dart';
export 'src/service/apps/i_app_service.dart';
export 'src/service/apps/impl/app_service.dart';
export 'src/service/command/i_command_service.dart';
export 'src/service/command/impl/command_service.dart';
export 'src/service/config/i_config_service.dart';
export 'src/service/config/impl/config_service.dart';
export 'src/service/config/shared/config_handler.dart';
export 'src/service/config/shared/impl/shared_prefs_handler.dart';
export 'src/service/data/i_data_service.dart';
export 'src/service/data/impl/data_service.dart';
export 'src/service/file/file_manager.dart';
export 'src/service/layout/i_layout_service.dart';
export 'src/service/layout/impl/layout_service.dart';
export 'src/service/storage/i_storage_service.dart';
export 'src/service/storage/impl/default/storage_service.dart';
export 'src/service/ui/i_ui_service.dart';
export 'src/service/ui/protect_config.dart';
export 'src/service/ui/impl/ui_service.dart';
// Util
export 'src/util/config_util.dart';
export 'src/util/debug/jvx_debug.dart';
export 'src/util/extensions/list_extensions.dart';
export 'src/util/extensions/string_extensions.dart';
export 'src/util/extensions/color_extensions.dart';
export 'src/util/extensions/double_extensions.dart';
export 'src/util/extensions/object_extensions.dart';
export 'src/util/icon_util.dart';
export 'src/util/i_clonable.dart';
export 'src/util/image/image_loader.dart';
export 'src/util/jvx_colors.dart';
export 'src/util/loading_handler/i_command_progress_handler.dart';
export 'src/util/misc/debouncer.dart';
export 'src/util/misc/dialog_result.dart';
export 'src/util/parse_util.dart';
export 'src/util/search_mixin.dart';
export 'src/util/stt/stt_capability.dart';
export 'src/util/tts/tts_capability.dart';
export 'src/util/widgets/jvx_scanner.dart';
export 'src/util/widgets/jvx_webview.dart';
export 'src/util/widgets/multi_value_listenable_builder.dart';
export 'src/util/widgets/progress/progress_button.dart';
export 'src/util/widgets/progress/progress_dialog_widget.dart';
export 'src/util/widgets/status_banner.dart';
