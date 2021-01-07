import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../injection_container.dart';
import '../../services/remote/bloc/api_bloc.dart';
import '../../utils/config/config.dart';
import '../../utils/theme/theme_manager.dart';
import '../widgets/page/startup_page_widget.dart';

class StartupPage extends StatelessWidget {
  static const String route = '/startup';
  final Config config;
  final bool shouldLoadConfig;

  const StartupPage({
    Key key,
    this.config,
    @required this.shouldLoadConfig,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: sl<ThemeManager>().themeData,
      child: BlocProvider<ApiBloc>(
        create: (_) => sl<ApiBloc>(),
        child: Scaffold(
          body: StartupPageWidget(
            config: this.config,
            shouldLoadConfig: this.shouldLoadConfig,
          ),
        ),
      ),
    );
  }
}
