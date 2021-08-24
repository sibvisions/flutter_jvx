import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../models/api/response_objects/response_data/component/changed_component.dart';
import '../../../models/api/response_objects/response_data/component/component_properties.dart';
import '../../../util/color/color_extension.dart';
import '../../screen/core/so_component_data.dart';
import '../../widgets/custom/custom_icon.dart';
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

  LatLng center = LatLng(48, 17);

  String? marker;

  String tileProvider = 'OpenStreetMap';

  int zoomLevel = 13;

  String? groupsDataBook;
  String? pointsDataBook;

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

    String? centerString =
        changedComponent.getProperty<String>(ComponentProperty.CENTER, null);

    if (centerString != null) {
      List<String> split = centerString.split(';');

      center = LatLng(
          double.tryParse(split.first) ?? 0, double.tryParse(split.last) ?? 0);
    }

    lineColor = HexColor.fromHex(changedComponent.getProperty<String>(
        ComponentProperty.LINE_COLOR, '')!);

    fillColor = HexColor.fromHex(changedComponent.getProperty<String>(
        ComponentProperty.FILL_COLOR, '')!);

    tileProvider = changedComponent.getProperty<String>(
        ComponentProperty.TILE_PROVIDER, tileProvider)!;

    groupsDataBook = changedComponent.getProperty<String>(
        ComponentProperty.GROUP_DATA_BOOK, '');
    pointsDataBook = changedComponent.getProperty<String>(
        ComponentProperty.POINTS_DATA_BOOK, '');

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

  void onGroupDataChanged(BuildContext context) {
    groups.clear();

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
        points: pointsForGroup,
        color: fillColor,
        borderColor: lineColor,
        borderStrokeWidth: 1.0));

    notifyListeners();
  }

  void onPointDataChanged(BuildContext context) {
    points.clear();

    if (pointsComponentData != null && pointsComponentData?.data != null) {
      for (final record in pointsComponentData!.data!.records) {
        int latIndex =
            pointsComponentData!.data!.getColumnIndex(latitudeColumnName);

        int longIndex =
            pointsComponentData!.data!.getColumnIndex(longitudeColumnName);

        if (latIndex >= 0 && longIndex >= 0) {
          double lat = record[latIndex] is int
              ? record[latIndex].toDouble()
              : record[latIndex];

          double long = record[longIndex] is int
              ? record[longIndex].toDouble()
              : record[longIndex];

          LatLng point = LatLng(lat, long);

          String? image = pointsComponentData!.data!.getValue(
              markerImageColumnName,
              pointsComponentData!.data!.records.indexOf(record));

          points.add(Marker(
              point: point,
              width: 64,
              height: 64,
              builder: (_) => Container(
                    child: image != null
                        ? CustomIcon(
                            image: image,
                            prefferedSize: Size(64, 64),
                          )
                        : CustomIcon(
                            image: marker ?? 'FontAwesome.mapMarker',
                            prefferedSize: Size(64, 64),
                          ),
                  )));
        }
      }

      notifyListeners();
    }
  }
}
