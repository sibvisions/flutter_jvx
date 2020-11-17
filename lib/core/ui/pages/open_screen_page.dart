import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../models/api/response.dart';
import '../../models/api/response/menu_item.dart';
import '../../models/app/app_state.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/page/open_screen_page_widget.dart';
import '../widgets/util/app_state_provider.dart';

class OpenScreenPage extends StatelessWidget {
  final String title;
  final Response response;
  final String menuComponentId;
  final String templateName;
  final List<MenuItem> items;

  const OpenScreenPage(
      {Key key,
      this.title,
      this.response,
      this.menuComponentId,
      this.templateName,
      this.items})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppState appState = AppStateProvider.of(context).appState;

    return Theme(
      data: sl<ThemeManager>().themeData,
      child: BlocProvider<ApiBloc>(
        create: (_) => sl<ApiBloc>(),
        child: OpenScreenPageWidget(
            title: this.title,
            response: this.response,
            menuComponentId: this.menuComponentId,
            templateName: this.templateName,
            items: this.items,
            appState: appState),
      ),
    );
  }
}
