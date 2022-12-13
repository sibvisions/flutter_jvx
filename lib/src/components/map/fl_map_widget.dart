/* Copyright 2022 SIB Visions GmbH
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

import 'package:flutter/widgets.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../model/component/map/fl_map_model.dart';
import '../base_wrapper/fl_stateless_widget.dart';

class FlMapWidget<T extends FlMapModel> extends FlStatelessWidget<T> {
  final List<Marker> markers;

  final List<Polygon> polygons;

  final MapController? mapController;

  final Function? onPressed;

  const FlMapWidget({
    super.key,
    required super.model,
    required this.markers,
    required this.polygons,
    this.mapController,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
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
        // Seems to be necessary even though it's the fallback
        minZoom: 0,
        maxZoom: 18,
        center: model.center,
      ),
      children: [
        TileLayer(
          urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
          subdomains: const ["a", "b", "c"],
        ),
        PolygonLayer(
          polygons: polygons,
        ),
        MarkerLayer(
          markers: markers,
          rotate: true,
        )
      ],
    );
  }
}
