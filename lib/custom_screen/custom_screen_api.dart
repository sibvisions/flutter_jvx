import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jvx_mobile_v3/custom_screen/first_custom_screen_api.dart';
import 'package:jvx_mobile_v3/custom_screen/i_custom_screen_api.dart';
import 'package:jvx_mobile_v3/logic/bloc/api_bloc.dart';
import 'package:jvx_mobile_v3/model/api/request/close_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/data/fetch_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/filter_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/insert_record.dart';
import 'package:jvx_mobile_v3/model/api/request/data/meta_data.dart' as meta;
import 'package:jvx_mobile_v3/model/api/request/data/save_data.dart';
import 'package:jvx_mobile_v3/model/api/request/data/select_record.dart';
import 'package:jvx_mobile_v3/model/api/request/data/set_values.dart';
import 'package:jvx_mobile_v3/model/api/request/navigation.dart';
import 'package:jvx_mobile_v3/model/api/request/open_screen.dart';
import 'package:jvx_mobile_v3/model/api/request/press_button.dart';
import 'package:jvx_mobile_v3/model/api/request/request.dart';
import 'package:jvx_mobile_v3/model/api/request/upload.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';
import 'package:jvx_mobile_v3/utils/globals.dart' as globals;

class CustomScreenApi implements ICustomScreenApi {
  CustomScreenApi();

  @override
  Widget getWidget() {
    return Container();
  }

  @override
  bool showCustomScreen() {
    return false;
  }

  @override
  setCustomScreenApi(CustomScreenApi customScreenApi) {
    globals.customScreenApi = customScreenApi;
  }

  @override
  Response getCurrentResponse(BuildContext context) {
    return BlocProvider.of<ApiBloc>(context).currentState;
  }

  _makeRequest(BuildContext context, Request request) {
    BlocProvider.of(context).dispatch(request);
  }

  @override
  closeScreen(BuildContext context, CloseScreen closeScreen) {
    _makeRequest(context, closeScreen);
  } 

  @override
  delete(BuildContext context, SelectRecord selectRecord) {
    _makeRequest(context, selectRecord);
  }

  @override
  fetch(BuildContext context, FetchData fetchData) {
    _makeRequest(context, fetchData);
  }

  @override
  filter(BuildContext context, FilterData filterData) {
    _makeRequest(context, filterData);
  }

  @override
  insert(BuildContext context, InsertRecord insertRecord) {
    _makeRequest(context, insertRecord);
  }

  @override
  metaData(BuildContext context, meta.MetaData metaData) {
    _makeRequest(context, metaData);
  }

  @override
  navigation(BuildContext context, Navigation navigation) {
    _makeRequest(context, navigation);
  }

  @override
  openScreen(BuildContext context, OpenScreen openScreen) {
    _makeRequest(context, openScreen);
  }

  @override
  pressButton(BuildContext context, PressButton pressButton) {
    _makeRequest(context, pressButton);
  }

  @override
  save(BuildContext context, SaveData saveData) {
    _makeRequest(context, saveData);
  }

  @override
  selectRecord(BuildContext context, SelectRecord selectRecord) {
    _makeRequest(context, selectRecord);
  }

  @override
  setValue(BuildContext context, SetValues setValues) {
    _makeRequest(context, setValues);
  }

  @override
  upload(BuildContext context, Upload upload) {
    _makeRequest(context, upload);
  }

  @override
  onMenuButtonPressed(BuildContext context, String label, String group) {
    // TODO: implement onMenuButtonPressed
    return null;
  }

  @override
  onResponse(Response response) {
    // TODO: implement onResponse
    return null;
  }
}
