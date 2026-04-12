/*
 * Copyright 2022 SIB Visions GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License"); you may not
 * use this file except in compliance with the License. You may obtain a copy of
 * the License at
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 * WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 * License for the specific language governing permissions and limitations under
 * the License.
 */

part of 'package:flutter_jvx/src/model/component/fl_component_model.dart';

class FlMapModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // Where the map should be centered
  LatLng? center;

  // List of Markers that will be shown on the map
  List<Marker> markers = [];

  // List of Polygons that will be shown on the map
  List<Polygon> polygons = [];

  // Zoom factor of map
  double zoomLevel = 8.5;

  // Fill Color
  Color? fillColor;

  // Line Color
  Color lineColor = JVxColors.LIGHTER_BLACK;

  // bool PointSelectionEnabled
  bool pointSelectionEnabled = true;

  // bool pointSelectionLockedOnCenter
  bool pointSelectionLockedOnCenter = false;

  // TitleProvider
  String tileProvider = "OpenStreetMap";

  String? groupDataBook;
  String? pointsDataBook;

  // layoutVal?:CSSProperties,
  // centerPosition?:MapLocation
  String groupColumnName = "GROUP";

  String latitudeColumnName = "LATITUDE";

  String longitudeColumnName = "LONGITUDE";

  String markerImageColumnName = "MARKER_IMAGE";

  String? markerImage;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlMapModel() : super() {
    preferredSize = const Size(300, 300);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  FlMapModel get defaultModel => FlMapModel();

  @override
  void applyFromJson(Map<String, dynamic> newJson) {
    super.applyFromJson(newJson);

    fillColor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.fillColor,
      defaultValue: defaultModel.fillColor,
      currentValue: fillColor,
      conversion: (e) => ParseUtil.parseColor(e)!,
    );

    tileProvider = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.tileProvider,
      defaultValue: defaultModel.tileProvider,
      currentValue: tileProvider,
    );

    lineColor = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.lineColor,
      defaultValue: defaultModel.lineColor,
      currentValue: lineColor,
      conversion: (e) => ParseUtil.parseColor(e)!,
    );

    groupDataBook = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.groupDataBook,
      defaultValue: defaultModel.groupDataBook,
      currentValue: groupDataBook,
    );

    markerImage = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.marker,
      defaultValue: defaultModel.markerImage,
      currentValue: markerImage,
    );

    center = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.center,
      defaultValue: defaultModel.center,
      currentValue: center,
      conversion: _parseLatLng,
    );

    pointsDataBook = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.pointsDataBook,
      defaultValue: defaultModel.pointsDataBook,
      currentValue: pointsDataBook,
    );

    groupColumnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.groupColumnName,
      defaultValue: defaultModel.groupColumnName,
      currentValue: groupColumnName,
    );

    latitudeColumnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.latitudeColumnName,
      defaultValue: defaultModel.latitudeColumnName,
      currentValue: latitudeColumnName,
    );

    longitudeColumnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.longitudeColumnName,
      defaultValue: defaultModel.longitudeColumnName,
      currentValue: longitudeColumnName,
    );

    markerImageColumnName = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.markerImageColumnName,
      defaultValue: defaultModel.markerImageColumnName,
      currentValue: markerImageColumnName,
    );

    pointSelectionEnabled = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.pointSelectionEnabled,
      defaultValue: defaultModel.pointSelectionEnabled,
      currentValue: pointSelectionEnabled,
    );

    pointSelectionLockedOnCenter = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.pointSelectionLockedOnCenter,
      defaultValue: defaultModel.pointSelectionLockedOnCenter,
      currentValue: pointSelectionLockedOnCenter,
    );

    zoomLevel = getPropertyValue(
      json: newJson,
      key: ApiObjectProperty.zoomLevel,
      defaultValue: defaultModel.zoomLevel,
      currentValue: zoomLevel,
      conversion: (value) => value.toDouble(),
    );
  }

  LatLng? _parseLatLng(dynamic value) {
    if (value != null && value is String) {
      List<String> centerStrings = value.split(",");
      return LatLng(double.tryParse(centerStrings.first) ?? 0, double.tryParse(centerStrings.last) ?? 0);
    }
    return null;
  }
}
