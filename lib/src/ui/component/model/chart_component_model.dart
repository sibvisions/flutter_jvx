import 'package:flutter/material.dart';
import 'package:flutterclient/src/models/api/response_objects/response_data/component/component_properties.dart';
import 'package:flutterclient/src/ui/screen/core/so_component_data.dart';
import 'package:flutterclient/src/ui/screen/core/so_screen.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import 'component_model.dart';

class ChartComponentModel extends ComponentModel {
  String xColumnName = '';
  String xColumnLabel = '';
  List<String> yColumnNames = [];
  List<String> yColumnLabels = [];

  String xAxisTitle = '';
  String yAxisTitle = '';

  String dataBook = '';

  SoComponentData? data;

  String title = '';

  // @override
  // get isPreferredSizeSet => this.preferredSize != null;

  // @override
  // get isMinimumSizeSet => this.minimumSize != null;

  ChartComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    xColumnName = changedComponent.getProperty<String>(
        ComponentProperty.X_COLUMN_NAME, xColumnName)!;

    yColumnNames = changedComponent.getProperty<List<String>>(
        ComponentProperty.Y_COLUMN_NAMES, yColumnNames)!;

    xColumnLabel = changedComponent.getProperty<String>(
        ComponentProperty.X_COLUMN_LABEL, xColumnLabel)!;

    yColumnLabels = changedComponent.getProperty<List<String>>(
        ComponentProperty.Y_COLUMN_LABELS, yColumnLabels)!;

    xAxisTitle = changedComponent.getProperty<String>(
        ComponentProperty.X_AXIS_TITLE, xAxisTitle)!;

    yAxisTitle = changedComponent.getProperty<String>(
        ComponentProperty.Y_AXIS_TITLE, yAxisTitle)!;

    title =
        changedComponent.getProperty<String>(ComponentProperty.TITLE, title)!;

    dataBook = changedComponent.getProperty<String>(
        ComponentProperty.DATA_BOOK, dataBook)!;

    super.updateProperties(context, changedComponent);
  }
}
