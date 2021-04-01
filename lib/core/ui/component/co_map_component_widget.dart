import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_component_data.dart';
import 'package:jvx_flutterclient/core/ui/screen/so_screen.dart';
import 'package:latlong/latlong.dart';

import 'component_widget.dart';
import 'models/map_component_model.dart';

class CoMapComponentWidget extends ComponentWidget {
  final MapComponentModel componentModel;

  CoMapComponentWidget({this.componentModel});

  @override
  State<StatefulWidget> createState() => CoMapComponentWidgetState();
}

class CoMapComponentWidgetState
    extends ComponentWidgetState<CoMapComponentWidget> {
  MapController _controller;

  SoComponentData pointsComponentData;
  SoComponentData groupComponentData;

  List<Polygon> _groups = <Polygon>[];
  List<Marker> _points = <Marker>[];

  _onPointSelection(LatLng latLng) {
    if (pointsComponentData != null &&
        widget.componentModel.pointSelectionEnabled) {
      pointsComponentData.setValues(context, [
        latLng.latitude,
        latLng.longitude
      ], [
        widget.componentModel.latitudeColumnName,
        widget.componentModel.longitudeColumnName
      ]);
    }
  }

  _onGroupDataChanged(BuildContext context) {
    List<LatLng> pointsForGroup = <LatLng>[];

    if (groupComponentData.data != null) {
      groupComponentData.data.records.forEach((record) {
        int latIndex = groupComponentData.data.getColumnIndex(
            widget.componentModel.latitudeColumnName ?? 'LATITUDE');
        int longIndex = groupComponentData.data.getColumnIndex(
            widget.componentModel.longitudeColumnName ?? 'LONGITUDE');

        double lat = record[latIndex] is int
            ? record[latIndex].toDouble()
            : record[latIndex];

        double long = record[longIndex] is int
            ? record[longIndex].toDouble()
            : record[longIndex];

        LatLng point = LatLng(lat, long);

        pointsForGroup.add(point);
      });
    }

    setState(() {
      _groups.add(Polygon(
          points: pointsForGroup,
          color: widget.componentModel.fillColor,
          borderColor: widget.componentModel.lineColor));
    });
  }

  _onPointDataChanged(BuildContext context) {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();

    _controller = MapController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      SoScreenState screen = SoScreen.of(context);

      pointsComponentData =
          screen.getComponentData(widget.componentModel.pointsDataBook);
      groupComponentData =
          screen.getComponentData(widget.componentModel.groupDataBook);

      pointsComponentData.registerDataChanged(_onPointDataChanged);
      groupComponentData.registerDataChanged(_onGroupDataChanged);

      pointsComponentData?.getData(context, -1);
      groupComponentData?.getData(context, -1);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (pointsComponentData?.data != null && groupComponentData?.data != null) {
      return FlutterMap(
        mapController: _controller,
        options: MapOptions(onTap: _onPointSelection, zoom: 13),
        children: [
          if (_points != null && _points.isNotEmpty)
            MarkerLayerWidget(options: MarkerLayerOptions(markers: _points)),
          if (_groups != null && _groups.isNotEmpty)
            PolygonLayerWidget(
              options: PolygonLayerOptions(polygons: _groups),
            ),
          TileLayerWidget(
            options: TileLayerOptions(
                urlTemplate:
                    "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c']),
          )
        ],
      );
    } else {
      return Center(
        child: Text('Loading...'),
      );
    }
  }
}
