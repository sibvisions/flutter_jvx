import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import '../../model/api/request/request.dart';
import '../../model/api/response/response.dart';
import '../../model/api/response/screen_generic.dart';
import '../../ui/screen/so_component_creator.dart';
import '../../ui/screen/so_screen.dart';

class ScreenBloc extends Bloc<Response, Widget> {
  SoScreen screen = SoScreen(SoComponentCreator());

  @override
  Widget get initialState => Container();

  @override
  Stream<Widget> mapEventToState(Response event) async* {
    if (isScreenRequest(event.requestType)) {
      ScreenGeneric screenGeneric = event.responseData.screenGeneric;
      screen.componentScreen.updateComponents(screenGeneric.changedComponents);
    }
    yield screen.getWidget();
  }
}
