import 'package:flutter/material.dart';

import '../../widgets/co_grid_layout.dart';
import '../../widgets/co_grid_layout_constraint.dart';
import '../co_layout_widget.dart';
import '../layout_model.dart';
import 'grid_layout_model.dart';

class CoGridLayoutContainerWidget extends CoLayoutWidget {
  final GridLayoutModel layoutModel;

  CoGridLayoutContainerWidget({required this.layoutModel})
      : super(layoutModel: layoutModel);

  @override
  CoLayoutWidgetState<CoGridLayoutContainerWidget> createState() =>
      CoGridLayoutWidgetState();
}

class CoGridLayoutWidgetState
    extends CoLayoutWidgetState<CoGridLayoutContainerWidget> {
  List<CoGridLayoutConstraintData> data = <CoGridLayoutConstraintData>[];

  List<CoGridLayoutConstraintData> _getConstraintData() {
    List<CoGridLayoutConstraintData> data = <CoGridLayoutConstraintData>[];

    widget.layoutModel.layoutConstraints.forEach((k, v) {
      CoGridLayoutConstraints? constraint =
          widget.layoutModel.getConstraintsFromString(v);

      if (constraint != null && k.componentModel.isVisible) {
        Key? key = widget.layoutModel
            .getKeyByComponentId(k.componentModel.componentId);

        if (key == null) {
          key = widget.layoutModel.createKey(k.componentModel.componentId);
        }

        constraint.comp = k;
        data.add(
            CoGridLayoutConstraintData(key: key, id: constraint, child: k));
      }
    });

    return data;
  }

  @override
  onChange() {
    if (mounted) {
      setState(() {
        data = _getConstraintData();
      });
    }
  }

  @override
  void initState() {
    super.initState();

    data = _getConstraintData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: CoGridLayoutWidget(
        key: layoutKey,
        container: widget.layoutModel.container!,
        children: data,
        rows: widget.layoutModel.rows,
        columns: widget.layoutModel.columns,
        margins: widget.layoutModel.margins,
        horizontalGap: widget.layoutModel.horizontalGap,
        verticalGap: widget.layoutModel.verticalGap,
      ),
    );
  }
}
