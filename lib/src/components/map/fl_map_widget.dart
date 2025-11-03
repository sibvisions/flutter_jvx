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

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../../flutter_jvx.dart';
import '../base_wrapper/fl_stateful_widget.dart';
import 'zoom_buttons_widget.dart';

class FlMapWidget<T extends FlMapModel> extends FlStatefulWidget<T> {

  static double markerSize = 32;

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
  State<FlMapWidget> createState() => _FlMapWidgetState();
}

class _FlMapWidgetState extends State<FlMapWidget> {

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: widget.mapController,
      options: MapOptions(
        onTap: (tapPosition, point) {
          if (widget.onPressed != null && widget.model.pointSelectionEnabled && !widget.model.pointSelectionLockedOnCenter) {
            widget.onPressed!(point);
          }
        },
        onPositionChanged: (MapCamera camera, bool hasGesture) {
          timer?.cancel();

          //don't send too many updates - only 1 if possible
          timer = Timer(const Duration(milliseconds: 250), () {
            if (widget.onPressed != null && widget.model.pointSelectionEnabled && widget.model.pointSelectionLockedOnCenter) {
              widget.onPressed!(widget.mapController?.camera.center);
            }
          });
        },
        initialZoom: widget.model.zoomLevel,
        // Seems to be necessary even though it's the fallback
        minZoom: 2,
        maxZoom: 19,
        initialCenter: LatLng.fromSexagesimal("48°12'30.56\"N, 16°22'19.49\"E"), //Vienna
      ),
      children: [
        TileLayer(
          urlTemplate: "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
          userAgentPackageName: 'com.sibvisions.flutter_jvx',
          tileProvider: NetworkTileProvider(),
        ),
        BasicAttributionWidget(),
        PolygonLayer(
          polygons: widget.polygons,
        ),
        MarkerLayer(
          markers: widget.markers,
          rotate: true,
        ),
        if (widget.model.pointSelectionLockedOnCenter && widget.model.pointSelectionEnabled)
        Container(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.only(bottom: FlMapWidget.markerSize) ,
            child: Icon(
              Icons.location_pin,
              color: Theme.of(context).colorScheme.primary,
              size: FlMapWidget.markerSize),
          )
        ),
        const FlutterMapZoomButtons(
          minZoom: 2,
          maxZoom: 19,
          mini: true,
          padding: 5,
          alignment: Alignment.bottomRight,
        ),
        //CustomPaint(painter: DebugPainter(), child: Container())
      ],
    );
  }
}

class BasicAttributionWidget extends StatelessWidget {
  /// Attribution text, such as 'OpenStreetMap contributors'
  final String? source;

  /// A basic, classic style, attribution widget
  const BasicAttributionWidget({
    super.key,
    this.source
  });

  @override
  Widget build(BuildContext context)
  {
    TextStyle? style = Theme.of(context).textTheme.bodyMedium;

    return SafeArea(
      child: Align(
        alignment: AlignmentGeometry.bottomRight,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.only(right: 5),
              child: Text(
                source ?? "© OpenStreetMap contributors",
                style: TextStyle(
                  color: style?.color?.withValues(alpha: 0.6) ?? Colors.black45,
                  fontSize: 12
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class DebugPainter extends CustomPainter { //         <-- CustomPainter class
  @override
  void paint(Canvas canvas, Size size) {
    Paint p = Paint()
      ..color = Colors.black
      ..strokeWidth = 0.1;

    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), p);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), p);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
