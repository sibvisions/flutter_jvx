import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../utils/translations.dart';
import '../../logic/bloc/api_bloc.dart';
import '../../logic/bloc/error_handler.dart';
import '../../model/api/request/open_screen.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../utils/globals.dart' as globals;
import '../page/open_screen_page.dart';

class MenuEmpty extends StatefulWidget {

  MenuEmpty({Key key})
      : super(key: key);

  @override
  _MenuEmptyState createState() => _MenuEmptyState();
}

class _MenuEmptyState extends State<MenuEmpty> {
  String title;

  bool errorMsgShown = false;

  @override
  Widget build(BuildContext context) {
    return errorAndLoadingListener(
      BlocListener<ApiBloc, Response>(
        listener: (context, state) {
          print("*** MenuEmpty - RequestType: " +
              state.requestType.toString());

          if (state != null && state.userData != null && globals.customScreenManager != null) {
            globals.customScreenManager.onUserData(state.userData);
          }

          if (state != null &&
              state.responseData.screenGeneric != null &&
              state.requestType == RequestType.OPEN_SCREEN ) {
            Key componentID = new Key(state.responseData.screenGeneric.componentId);

            Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => new OpenScreenPage(
                      screenGeneric: state.responseData.screenGeneric,
                      responseData: state.responseData,
                      request: state.request,
                      componentId: componentID,
                      title: title,
                      items: globals.items,
                      menuComponentId: (state.request as OpenScreen).action.componentId,
                    )));
          }
        },
        child: Center(
          child: Text(Translations.of(context)
                    .text2('Choose Item', 'Choose Item')),
        )
      ),
    );
  }
}
