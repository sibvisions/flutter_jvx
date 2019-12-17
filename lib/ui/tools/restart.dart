import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/reload.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

typedef Widget LoadConfigBuilder(bool loadConf);

class RestartWidget extends StatefulWidget {
  LoadConfigBuilder loadConfigBuilder;

  RestartWidget({
    Key key,
    this.loadConfigBuilder,
  }) : super(key: key);

  static restartApp(BuildContext context, {bool loadConf = false}) {
    final _RestartWidgetState state =
      context.findAncestorStateOfType<_RestartWidgetState>();
    
    state.restartApp(loadConf);
  }

  _RestartWidgetState createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = new UniqueKey();
  bool loadConf = true;

  void restartApp(bool loadConfig) {
    this.loadConf = loadConfig;
    this.setState(() {
      BlocProvider.of<ApiBloc>(context).dispatch(Reload(requestType: RequestType.RELOAD));
      key = new UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: key,
      child: widget.loadConfigBuilder((this.loadConf == null || this.loadConf) ? true : false),
    );
  }
}