import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong/latlong.dart';

import '../../screen/core/so_component_data.dart';
import '../../screen/core/so_data_screen.dart';
import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import 'component_model.dart';

class MapComponentModel extends ComponentModel {
  String groupColumnName = 'GROUP';
  String latitudeColumnName = 'LATITUDE';
  String longitudeColumnName = 'LONGITUDE';
  String markerImageColumnName = 'MARKER_IMAGE';

  bool pointSelectionEnabled = false;
  bool pointSelectionLockedOnCenter = false;

  Color fillColor = Colors.white;
  Color lineColor = Colors.black;

  String? center;

  String? marker;

  String tileProvider = 'OpenStreetMap';

  int zoomLevel = 13;

  SoComponentData? groupsComponentData;
  SoComponentData? pointsComponentData;

  List<Polygon> groups = <Polygon>[];
  List<Marker> points = <Marker>[];

  MapComponentModel({required ChangedComponent changedComponent})
      : super(changedComponent: changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    groupColumnName = changedComponent.getProperty<String>(
        ComponentProperty.GROUP_COLUMN_NAME, groupColumnName)!;
    latitudeColumnName = changedComponent.getProperty<String>(
        ComponentProperty.LATITUDE_COLUMN_NAME, latitudeColumnName)!;
    longitudeColumnName = changedComponent.getProperty<String>(
        ComponentProperty.LONGITUDE_COLUMN_NAME, longitudeColumnName)!;
    markerImageColumnName = changedComponent.getProperty<String>(
        ComponentProperty.MARKER_IMAGE_COLUMN_NAME, markerImageColumnName)!;
    pointSelectionLockedOnCenter = changedComponent.getProperty<bool>(
        ComponentProperty.POINT_SELECTION_LOCKED_ON_CENTER,
        pointSelectionLockedOnCenter)!;
    zoomLevel = changedComponent.getProperty<int>(
        ComponentProperty.ZOOM_LEVEL, zoomLevel)!;
    pointSelectionEnabled = changedComponent.getProperty<bool>(
        ComponentProperty.POINT_SELECTION_ENABLED, pointSelectionEnabled)!;
    marker =
        changedComponent.getProperty<String>(ComponentProperty.MARKER, marker);

    center =
        changedComponent.getProperty<String>(ComponentProperty.CENTER, center);

    lineColor = changedComponent.getProperty<Color>(
        ComponentProperty.LINE_COLOR, lineColor)!;

    fillColor = changedComponent.getProperty<Color>(
        ComponentProperty.FILL_COLOR, fillColor)!;

    tileProvider = changedComponent.getProperty<String>(
        ComponentProperty.TILE_PROVIDER, tileProvider)!;

    final groupsDataBook = changedComponent.getProperty<String>(
        ComponentProperty.GROUP_DATA_BOOK, '');
    final pointsDataBook = changedComponent.getProperty<String>(
        ComponentProperty.POINTS_DATA_BOOK, '');

    if (groupsDataBook != null)
      groupsComponentData = SoComponentData(
          dataProvider: groupsDataBook,
          soDataScreen: context.widget as SoDataScreen);

    if (pointsDataBook != null)
      pointsComponentData = SoComponentData(
          dataProvider: pointsDataBook,
          soDataScreen: context.widget as SoDataScreen);

    super.updateProperties(context, changedComponent);
  }

  void onPointSelection(BuildContext context, LatLng latLng) {
    if (pointsComponentData != null && pointSelectionEnabled) {
      pointsComponentData!.setValues(
          context,
          [latLng.latitude, latLng.longitude],
          [latitudeColumnName, longitudeColumnName]);
    }
  }

  void onGroupDataChanged() {
    List<LatLng> pointsForGroup = <LatLng>[];

    if (groupsComponentData != null && groupsComponentData?.data != null) {
      for (final record in groupsComponentData!.data!.records) {
        int latIndex =
            groupsComponentData!.data!.getColumnIndex(latitudeColumnName);

        int longIndex =
            groupsComponentData!.data!.getColumnIndex(longitudeColumnName);

        if (latIndex >= 0 && longIndex >= 0) {
          double lat = record[latIndex] is int
              ? record[latIndex].toDouble()
              : record[latIndex];

          double long = record[longIndex] is int
              ? record[longIndex].toDouble()
              : record[longIndex];

          LatLng point = LatLng(lat, long);

          pointsForGroup.add(point);
        }
      }
    }

    groups.add(Polygon(
        points: pointsForGroup, color: fillColor, borderColor: lineColor));

    notifyListeners();
  }

  void onPointDataChanged() => notifyListeners();
}
