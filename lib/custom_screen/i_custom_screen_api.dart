import 'package:flutter/widgets.dart';
import 'package:jvx_mobile_v3/custom_screen/custom_screen_api.dart';
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
import 'package:jvx_mobile_v3/model/api/request/upload.dart';
import 'package:jvx_mobile_v3/model/api/response/response.dart';

abstract class ICustomScreenApi {
  Widget getWidget();

  bool showCustomScreen();

  openScreen(BuildContext context, OpenScreen openScreen);

  closeScreen(BuildContext context, CloseScreen closeScreen);

  selectRecord(BuildContext context, SelectRecord selectRecord);

  setValue(BuildContext context, SetValues setValues);

  fetch(BuildContext context, FetchData fetchData);

  delete(BuildContext context, SelectRecord selectRecord);

  filter(BuildContext context, FilterData filterData);

  insert(BuildContext context, InsertRecord insertRecord);

  save(BuildContext context, SaveData saveData);

  metaData(BuildContext context, meta.MetaData metaData);

  pressButton(BuildContext context, PressButton pressButton);

  navigation(BuildContext context, Navigation navigation);

  upload(BuildContext context, Upload upload);

  setCustomScreenApi(CustomScreenApi customScreenApi);

  Response getCurrentResponse(BuildContext context);

  onResponse(Response response);

  onMenuButtonPressed(BuildContext context, String label, String group);
}