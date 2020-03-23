import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/api/response/screen_generic.dart';
import '../../ui/screen/component_creator.dart';
import '../../ui/screen/screen.dart';

class ScreenBloc extends Bloc<Response, Widget> {
  JVxScreen screen = JVxScreen(ComponentCreator());

  @override
  Widget get initialState => Container();

  @override
  Stream<Widget> mapEventToState(Response event) async* {
    if (isScreenRequest(event.requestType)) {
      ScreenGeneric screenGeneric = event.responseData.screenGeneric;
      //List<JVxData> data = event.jVxData;
      //List<JVxMetaData> metaData = event.jVxMetaData;
      screen.componentScreen.updateComponents(screenGeneric.changedComponents);
    }
    yield screen.getWidget();
  }
}