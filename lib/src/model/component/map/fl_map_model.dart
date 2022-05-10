import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../../util/parse_util.dart';
import '../../api/api_object_property.dart';
import '../fl_component_model.dart';

class FlMapModel extends FlComponentModel {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  //MarkerTemplate
  Marker marker =
      Marker(point: LatLng(48, 17), width: 64, height: 64, builder: (_) => const FaIcon(FontAwesomeIcons.mapMarker));

  //Where the map should be centered
  LatLng? center = LatLng(48, 17);

  //List of Markers that will be shown on the map
  List<Marker> markers = [];

  //List of Polygons that will be shown on the map
  List<Polygon> polygons = [];

  //Map Controller
  MapController? controller;

  //Zoom factor of map
  double zoom = 13;

  //Api Key
  String? apiKey;

  //Fill Color
  Color fillColor = Colors.white;

  //Line Color
  Color lineColor = Colors.black;

  //bool PointSelectionEnabled
  bool pointSelectionEnabled = false;

  //bool pointSelectionLockedOnCenter
  bool pointSelectionLockedOnCenter = false;

  //TitleProvider
  String tileProvider = 'OpenStreetMap';

  String? groupDataBook;
  String? pointsDataBook;

  //layoutVal?:CSSProperties,
  //centerPosition?:MapLocation
  String groupColumnName = 'GROUP';
  String latitudeColumnName = 'LATITUDE';
  String longitudeColumnName = 'LONGITUDE';
  String markerImageColumnName = 'MARKER_IMAGE';

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Initialization
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  FlMapModel() : super() {
    preferredSize = const Size(300, 300);
    markers.add(marker);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Overridden methods
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  @override
  void applyFromJson(Map<String, dynamic> pJson) {
    super.applyFromJson(pJson);

    var jsonFillColor = pJson[ApiObjectProperty.fillColor];
    if (jsonFillColor != null) {
      fillColor = ParseUtil.parseServerColor(jsonFillColor)!;
    }

    var jsonTileProvider = pJson[ApiObjectProperty.tileProvider];
    if (jsonTileProvider != null) {
      tileProvider = jsonTileProvider;
    }

    var jsonlineColor = pJson[ApiObjectProperty.lineColor];
    if (jsonlineColor != null) {
      lineColor = ParseUtil.parseServerColor(jsonlineColor)!;
    }

    var jsonGroupDataBook = pJson[ApiObjectProperty.groupDataBook];
    if (jsonGroupDataBook != null) {
      groupDataBook = jsonGroupDataBook;
    }

    var jsonPointsDataBook = pJson[ApiObjectProperty.pointsDataBook];
    if (jsonPointsDataBook != null) {
      pointsDataBook = jsonPointsDataBook;
    }
  }
}
