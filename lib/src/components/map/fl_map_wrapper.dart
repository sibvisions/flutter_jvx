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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../model/command/api/set_values_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../../service/api/shared/api_object_property.dart';
import '../../service/command/i_command_service.dart';
import '../../service/ui/i_ui_service.dart';
import '../../util/image/image_loader.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_map_widget.dart';

class FlMapWrapper extends BaseCompWrapperWidget<FlMapModel> {
  const FlMapWrapper({super.key, required super.model});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlMapWrapperState();
}

class _FlMapWrapperState extends BaseCompWrapperState<FlMapModel> {
  DataChunk? _chunkData;

  List<Marker> markers = [];

  List<Polygon> polygons = [];

  MapController mapController = MapController();

  bool initCenter = true;

  _FlMapWrapperState() : super();

  @override
  void initState() {
    super.initState();

    _subscribe();
  }

  @override
  Widget build(BuildContext context) {
    final FlMapWidget widget = FlMapWidget(
      model: model,
      markers: markers,
      polygons: polygons,
      onPressed: onPointSelection,
      mapController: mapController,
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return wrapWidget(context, widget);
  }

  @override
  void dispose() {
    _unsubscribe();
    super.dispose();
  }

  @override
  void beforeModelUpdate(Set<String> changedProperties) {
    if (changedProperties.contains(ApiObjectProperty.pointsDataBook)
        || changedProperties.contains(ApiObjectProperty.groupDataBook)) {
      _unsubscribe();
    }
  }

  @override
  modelUpdated() {
    super.modelUpdated();

    bool applyCenter = false;

    if (model.lastChangedProperties.contains(ApiObjectProperty.center)) {
      initCenter = true;
      applyCenter = true;
    }

    if (model.lastChangedProperties.contains(ApiObjectProperty.pointsDataBook)
        || model.lastChangedProperties.contains(ApiObjectProperty.groupDataBook)) {

      initCenter = true;
      applyCenter = false;

      _subscribe();
    }

    if (applyCenter) {
      if (initCenter && model.center != null) {
        mapController.move(model.center!, mapController.camera.zoom);

        initCenter = false;
      }

    }
  }

  void _subscribe() {
    if (model.pointsDataBook != null) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          from: 0,
          dataProvider: model.pointsDataBook!,
          onDataChunk: receiveMarkerData,
          dataColumns: [
            model.markerImageColumnName,
            model.latitudeColumnName,
            model.longitudeColumnName,
          ],
        ),
      );
    }

    if (model.groupDataBook != null) {
      IUiService().registerDataSubscription(
        pDataSubscription: DataSubscription(
          subbedObj: this,
          from: 0,
          dataProvider: model.groupDataBook!,
          onDataChunk: receivePolygonData,
          dataColumns: [
            model.groupColumnName,
            model.latitudeColumnName,
            model.longitudeColumnName,
          ],
        ),
      );
    }
  }

  void _unsubscribe() {
    if (model.groupDataBook != null) {
      IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.groupDataBook);
    }

    if (model.pointsDataBook != null) {
      IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.pointsDataBook);
    }
  }

  void receivePolygonData(DataChunk pChunkData) {
    _chunkData = pChunkData;

    polygons.clear();

    Map<String, List<LatLng>> polygonPointsGrouped = <String, List<LatLng>>{};

    for (List<dynamic> dataRow in _chunkData!.data.values) {
      String groupName = dataRow[0];

      double lat = dataRow[1] is int ? dataRow[1].toDouble() : dataRow[1];

      double long = dataRow[2] is int ? dataRow[2].toDouble() : dataRow[2];

      LatLng point = LatLng(lat, long);

      List<LatLng> group = polygonPointsGrouped[groupName] ?? [];
      group.add(point);
      polygonPointsGrouped[groupName] = group;
    }

    for (List<LatLng> pointList in polygonPointsGrouped.values) {
      polygons.add(Polygon(
        points: pointList,
        color: model.fillColor,
        borderColor: model.lineColor,
        borderStrokeWidth: 1,
      ));
    }

    setState(() {});
  }

  void receiveMarkerData(DataChunk pChunkData) {
    _chunkData = pChunkData;

    markers.clear();

    for (List<dynamic> dataRow in _chunkData!.data.values) {
      String? image = dataRow[0];

      double lat = dataRow[1] is int ? dataRow[1].toDouble() : dataRow[1];

      double long = dataRow[2] is int ? dataRow[2].toDouble() : dataRow[2];

      LatLng point = LatLng(lat, long);

      markers.add(getMarker(image, point));
    }

    if (initCenter && model.center == null && markers.isNotEmpty) {
      mapController.move(markers.last.point, mapController.camera.zoom);

      initCenter = false;
    }

    //if lockOnCenter is enabled, we remove the last marker because we have a special layer for this use-case
    if (model.pointSelectionEnabled && model.pointSelectionLockedOnCenter && markers.isNotEmpty) {
      markers.removeLast();
    }

    setState(() {});
  }

  void onPointSelection(LatLng latLng) {
    if (model.pointSelectionEnabled && model.pointsDataBook != null) {
      ICommandService().sendCommand(
        SetValuesCommand(
          dataProvider: model.pointsDataBook!,
          columnNames: [model.latitudeColumnName, model.longitudeColumnName],
          values: [latLng.latitude, latLng.longitude],
          reason: "Clicked on Map",
        ),
      );
    }
  }

  Marker getMarker(String? image, LatLng point) {
    if (image != null || model.markerImage != null) {
      return Marker(
        point: point,
        width: FlMapWidget.markerSize,
        height: FlMapWidget.markerSize,
        child: ImageLoader.loadImage(
          image ?? model.markerImage!,
          width: FlMapWidget.markerSize,
          height: FlMapWidget.markerSize,
        ),
      );
    } else {
      // OverflowBox is used to remove the spacing between the icon and the actual point
      return Marker(
        point: point,
        alignment: Alignment.topCenter,
        width: FlMapWidget.markerSize,
        height: FlMapWidget.markerSize,
        child: Icon(
          Icons.location_pin,
          size: FlMapWidget.markerSize,
          color: Theme.of(context).colorScheme.primary,
        ),
      );
    }
  }
}
