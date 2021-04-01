import 'package:flutter/cupertino.dart';
import 'package:latlong/latlong.dart';
import '../../../models/api/component/changed_component.dart';
import '../../../models/api/component/component_properties.dart';
import 'component_model.dart';
import '../../../utils/theme/hex_color.dart';

class MapComponentModel extends ComponentModel {
  String apiKey;
  String groupColumnName;
  String latitudeColumnName;
  String longitudeColumnName;
  String markerImageColumnName;
  bool pointSelectionLockedOnCenter;
  LatLng center;
  int zoomLevel;
  bool pointSelectionEnabled;
  String marker;
  HexColor lineColor;
  HexColor fillColor;
  String tileProvider;

  String groupDataBook;
  String pointsDataBook;

  MapComponentModel(ChangedComponent changedComponent)
      : super(changedComponent);

  @override
  void updateProperties(
      BuildContext context, ChangedComponent changedComponent) {
    apiKey = changedComponent.getProperty<String>(ComponentProperty.API_KEY);
    groupColumnName = changedComponent
        .getProperty<String>(ComponentProperty.GROUP_COLUMN_NAME);
    latitudeColumnName = changedComponent
        .getProperty<String>(ComponentProperty.LATITUDE_COLUMN_NAME);
    longitudeColumnName = changedComponent
        .getProperty<String>(ComponentProperty.LONGITUDE_COLUMN_NAME);
    markerImageColumnName = changedComponent
        .getProperty<String>(ComponentProperty.MARKER_IMAGE_COLUMN_NAME);
    pointSelectionLockedOnCenter = changedComponent
        .getProperty<bool>(ComponentProperty.POINT_SELECTION_LOCKED_ON_CENTER);
    zoomLevel = changedComponent.getProperty<int>(ComponentProperty.ZOOM_LEVEL);
    pointSelectionEnabled = changedComponent
        .getProperty<bool>(ComponentProperty.POINT_SELECTION_ENABLED);
    marker = changedComponent.getProperty<String>(ComponentProperty.MARKER);

    final newCenter = changedComponent
        ?.getProperty<String>(ComponentProperty.CENTER)
        ?.split(',');

    if (newCenter != null)
      center = LatLng(double.parse(newCenter[0]), double.parse(newCenter[1]));

    String newLineColor =
        changedComponent.getProperty<String>(ComponentProperty.LINE_COLOR);
    lineColor = newLineColor != null && HexColor.isHexColor(newLineColor)
        ? HexColor(newLineColor)
        : null;

    String newFillColor =
        changedComponent.getProperty<String>(ComponentProperty.FILL_COLOR);

    fillColor = newFillColor != null && HexColor.isHexColor(newFillColor)
        ? HexColor(newFillColor)
        : null;

    tileProvider =
        changedComponent.getProperty<String>(ComponentProperty.TILE_PROVIDER);

    groupDataBook =
        changedComponent.getProperty<String>(ComponentProperty.GROUP_DATA_BOOK);
    pointsDataBook = changedComponent
        .getProperty<String>(ComponentProperty.POINTS_DATA_BOOK);

    super.updateProperties(context, changedComponent);
  }
}
