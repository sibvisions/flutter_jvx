import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:latlong2/latlong.dart';

import '../../../services.dart';
import '../../../util/image/image_loader.dart';
import '../../model/command/api/set_values_command.dart';
import '../../model/component/fl_component_model.dart';
import '../../model/component/map/fl_map_model.dart';
import '../../model/data/subscriptions/data_chunk.dart';
import '../../model/data/subscriptions/data_subscription.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';
import 'fl_map_widget.dart';

class FlMapWrapper extends BaseCompWrapperWidget<FlMapModel> {
  const FlMapWrapper({super.key, required super.id});

  @override
  BaseCompWrapperState<FlComponentModel> createState() => _FlMapWrapperState();
}

class _FlMapWrapperState extends BaseCompWrapperState<FlMapModel> {
  DataChunk? _chunkData;

  List<Marker> markers = [];

  List<Polygon> polygons = [];

  MapController mapController = MapController();

  @override
  void initState() {
    super.initState();
    subscribe();
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

    return getPositioned(child: widget);
  }

  @override
  void dispose() {
    unsubscribe();
    super.dispose();
  }

  @override
  receiveNewModel(FlMapModel pModel) {
    super.receiveNewModel(pModel);
    unsubscribe();
    subscribe();
  }

  void subscribe() {
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

  void unsubscribe() {
    if (model.groupDataBook != null) {
      IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.groupDataBook!);
    }

    if (model.pointsDataBook != null) {
      IUiService().disposeDataSubscription(pSubscriber: this, pDataProvider: model.pointsDataBook!);
    }
  }

  void receivePolygonData(DataChunk pChunkData) {
    if (pChunkData.update && _chunkData != null) {
      for (int index in pChunkData.data.keys) {
        _chunkData!.data[index] = pChunkData.data[index]!;
      }
    } else {
      _chunkData = pChunkData;
    }

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
        isFilled: true,
        color: model.fillColor,
        borderColor: model.lineColor,
        borderStrokeWidth: 1,
      ));
    }

    setState(() {});
  }

  void receiveMarkerData(DataChunk pChunkData) {
    if (pChunkData.update && _chunkData != null) {
      for (int index in pChunkData.data.keys) {
        _chunkData!.data[index] = pChunkData.data[index]!;
      }
    } else {
      _chunkData = pChunkData;
    }

    markers.clear();

    for (List<dynamic> dataRow in _chunkData!.data.values) {
      String? image = dataRow[0];

      double lat = dataRow[1] is int ? dataRow[1].toDouble() : dataRow[1];

      double long = dataRow[2] is int ? dataRow[2].toDouble() : dataRow[2];

      LatLng point = LatLng(lat, long);

      markers.add(getMarker(image, point));
    }
    setState(() {});
  }

  void onPointSelection(LatLng latLng) {
    if (model.pointSelectionEnabled && model.pointsDataBook != null) {
      IUiService().sendCommand(
        SetValuesCommand(
          componentId: model.id,
          dataProvider: model.pointsDataBook!,
          columnNames: [model.latitudeColumnName, model.longitudeColumnName],
          values: [latLng.latitude, latLng.longitude],
          reason: "Clicked on Map",
        ),
      );
    }
  }

  Marker getMarker(String? image, LatLng point) {
    Widget img;
    if (image != null) {
      img = ImageLoader.loadImage(
        image,
        pWantedSize: const Size(64, 64),
      );
    } else if (model.markerImage != null) {
      img = ImageLoader.loadImage(
        model.markerImage!,
        pWantedSize: const Size(64, 64),
      );
    } else {
      img = FaIcon(
        FontAwesomeIcons.locationPin,
        size: 64,
        color: Theme.of(context).primaryColor,
      );
    }
    return (Marker(
      point: point,
      width: 64,
      height: 64,
      builder: (_) => img,
    ));
  }
}
