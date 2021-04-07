import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../layout/i_alignment_constants.dart';
import 'co_cell_editor_widget.dart';
import 'models/image_cell_editor_model.dart';

class CoImageCellEditorWidget extends CoCellEditorWidget {
  CoImageCellEditorWidget({
    required ImageCellEditorModel cellEditorModel,
    Key? key,
  }) : super(key: key, cellEditorModel: cellEditorModel);

  @override
  CoCellEditorWidgetState<CoImageCellEditorWidget> createState() =>
      CoImageCellEditorWidgetState();
}

class CoImageCellEditorWidgetState
    extends CoCellEditorWidgetState<CoImageCellEditorWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double? height = constraints.maxHeight != double.infinity
            ? constraints.maxHeight
            : null;
        double? width = constraints.maxWidth != double.infinity
            ? constraints.maxWidth
            : null;

        return Container(
          child: Row(
            mainAxisAlignment: IAlignmentConstants.getMainAxisAlignment(
                widget.cellEditorModel.horizontalAlignment),
            children: [
              Card(
                color: Colors.white.withOpacity(widget.cellEditorModel.appState
                        .applicationStyle?.controlsOpacity ??
                    1.0),
                elevation: 2.0,
                shape: widget.cellEditorModel.appState.applicationStyle
                        ?.editorsShape ??
                    RoundedRectangleBorder(),
                child: Container(
                  height: height ?? 100,
                  width: width != null ? width - 10.0 : null,
                  decoration: BoxDecoration(
                      image: (widget.cellEditorModel as ImageCellEditorModel)
                          .getImage(height ?? 0,
                              widget.cellEditorModel.horizontalAlignment),
                      color: widget.cellEditorModel.backgroundColor != null
                          ? widget.cellEditorModel.backgroundColor
                          : Colors.transparent),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
