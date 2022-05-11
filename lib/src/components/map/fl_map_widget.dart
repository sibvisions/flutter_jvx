import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../model/component/map/fl_map_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlMapWidget<T extends FlMapModel> extends FlStatelessWidget<T> {
  final List<Marker> markers;

  final List<Polygon> polygons;

  final MapController? mapController;

  final Function? onPressed;

  const FlMapWidget(
      {Key? key, required T model, required this.markers, required this.polygons, this.mapController, this.onPressed})
      : super(key: key, model: model);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      layers: [
        MarkerLayerOptions(
          markers: markers,
        ),
        PolygonLayerOptions(
          polygons: polygons,
        ),
      ],
      mapController: mapController,
      options: MapOptions(
        onTap: (tapPosition, point) {
          if (onPressed != null && !model.pointSelectionLockedOnCenter) {
            onPressed!(point);
          }
        },
        onPositionChanged: (MapPosition mapPosition, bool boolean) {
          if (model.pointSelectionLockedOnCenter && onPressed != null) {
            onPressed!(mapController?.center);
          }
        },
        zoom: model.zoomLevel,
        center: model.center,
      ),
      children: [
        TileLayerWidget(
            options: TileLayerOptions(
                urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', subdomains: ['a', 'b', 'c']))
      ],
    );
  }
}
