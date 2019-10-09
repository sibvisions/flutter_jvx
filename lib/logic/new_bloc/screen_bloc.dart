import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/model/data/data/jvx_data.dart';
import 'package:jvx_mobile_v3/model/data/meta_data/jvx_meta_data.dart';
import 'package:jvx_mobile_v3/model/screen_generic.dart';
import 'package:jvx_mobile_v3/ui/screen/component_creator.dart';
import 'package:jvx_mobile_v3/ui/screen/screen.dart';

class ScreenBloc extends Bloc<Response, Widget> {
  JVxScreen screen = JVxScreen(ComponentCreator());

  @override
  Widget get initialState => Container();

  @override
  Stream<Widget> mapEventToState(Response event) async* {
    if (isScreenRequest(event.requestType)) {
      ScreenGeneric screenGeneric = event.screenGeneric;
      List<JVxData> data = event.jVxData;
      List<JVxMetaData> metaData = event.jVxMetaData;
      screen.updateComponents(screenGeneric.changedComponents);
    }
    yield screen.getWidget();
  }
}