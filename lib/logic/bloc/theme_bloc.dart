import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:jvx_mobile_v3/utils/uidata.dart';

class ThemeBloc extends Bloc<ThemeData, ThemeData> {
  @override
  ThemeData get initialState => ThemeData(
    primaryColor: UIData.ui_kit_color_2,
    primarySwatch: UIData.ui_kit_color_2,
    fontFamily: UIData.ralewayFont,
  );

  @override
  Stream<ThemeData> mapEventToState(ThemeData event) async* {
    yield event;
  }
  
}