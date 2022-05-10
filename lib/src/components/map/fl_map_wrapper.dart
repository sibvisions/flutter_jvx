import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_client/src/components/map/fl_map_widget.dart';
import 'package:flutter_client/src/mixin/ui_service_mixin.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_data.dart';
import 'package:flutter_client/src/model/data/chunk/chunk_subscription.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../model/component/map/fl_map_model.dart';
import '../base_wrapper/base_comp_wrapper_state.dart';
import '../base_wrapper/base_comp_wrapper_widget.dart';

class FlMapWrapper extends BaseCompWrapperWidget<FlMapModel> {
  FlMapWrapper({Key? key, required String id}) : super(key: key, id: id);

  @override
  _FlMapWrapperState createState() => _FlMapWrapperState();
}

class _FlMapWrapperState extends BaseCompWrapperState<FlMapModel> with UiServiceMixin {
  final List<Marker> markers = [];

  final List<Polygon> polygons = [];

  @override
  Widget build(BuildContext context) {
    final FlMapWidget widget = FlMapWidget(
      model: model,
      markers: markers,
      polygons: polygons,
    );

    SchedulerBinding.instance!.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    return getPositioned(child: widget);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    if (model.groupDataBook != null) {
      uiService.registerDataChunk(
        chunkSubscription: ChunkSubscription(
          id: model.id,
          from: 0,
          dataProvider: model.groupDataBook!,
          callback: receivePolygonData,
          dataColumns: [
            model.groupColumnName,
            model.latitudeColumnName,
            model.longitudeColumnName,
          ],
          to: double.maxFinite.toInt(),
        ),
      );
    }
  }

  void receivePolygonData(ChunkData pChunkData) {
    polygons.clear();

    Map<String, List<LatLng>> polygonPointsGrouped = <String, List<LatLng>>{};

    for (List<dynamic> dataRow in pChunkData.data.values) {
      String groupName = dataRow[0];

      double lat = dataRow[1] is int ? dataRow[1].toDouble() : dataRow[1];

      double long = dataRow[2] is int ? dataRow[2].toDouble() : dataRow[2];

      LatLng point = LatLng(lat, long);

      List<LatLng> group = polygonPointsGrouped[groupName] ?? [];
      group.add(point);
    }

    for (List<LatLng> pointList in polygonPointsGrouped.values) {
      polygons
          .add(Polygon(points: pointList, color: model.fillColor, borderColor: model.lineColor, borderStrokeWidth: 1));
    }

    // setState(() {});
  }
}
