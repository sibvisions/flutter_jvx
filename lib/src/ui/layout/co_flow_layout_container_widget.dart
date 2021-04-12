import 'package:flutter/material.dart';

import '../component/component_widget.dart';
import '../container/co_container_widget.dart';
import '../widgets/builder/custom_stateful_builder.dart';
import 'co_layout.dart';
import 'i_alignment_constants.dart';
import 'widgets/co_flow_layout_widget.dart';

class CoFlowLayoutContainerWidget extends StatelessWidget
    with CoLayout<String> {
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // Class members
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  // the horizontal alignment.
  int horizontalAlignment = IAlignmentConstants.ALIGN_CENTER;
  // the vertical alignment.
  int verticalAlignment = IAlignmentConstants.ALIGN_CENTER;

  // the orientation.
  int orientation = 0;

  // the component alignment. */
  int horizontalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;
  int verticalComponentAlignment = IAlignmentConstants.ALIGN_CENTER;

  bool autoWrap = false;

  /// stores all constraints. */
  Map<ComponentWidget, String> _constraintMap = <ComponentWidget, String>{};

  List<CoFlowLayoutConstraintData> children = <CoFlowLayoutConstraintData>[];

  CoFlowLayoutContainerWidget(Key key) : super(key: key);

  CoFlowLayoutContainerWidget.fromLayoutString(
      CoContainerWidget pContainer, String layoutString, String layoutData) {
    updateLayoutString(layoutString);
    this.container = pContainer;
  }

  @override
  void updateLayoutString(String layoutString) {
    super.updateLayoutString(layoutString);
    parseFromString(layoutString);

    List<String> parameter = layoutString.split(",");

    orientation = int.parse(parameter[7]);
    horizontalAlignment = int.parse(parameter[8]);
    verticalAlignment = int.parse(parameter[9]);
    horizontalComponentAlignment = int.parse(parameter[10]);
    autoWrap = (parameter[11] == 'true') ? true : false;
    verticalComponentAlignment = horizontalComponentAlignment;
  }

  @override
  void addLayoutComponent(ComponentWidget pComponent, String pConstraint) {
    if (setState != null) {
      setState!(() {
        _constraintMap.putIfAbsent(pComponent, () => pConstraint);

        // if (pComponent.componentModel.isVisible) {
        //   Key key =
        //       this.getKeyByComponentId(pComponent.componentModel.componentId);

        //   if (key == null) {
        //     key = this.createKey(pComponent.componentModel.componentId);
        //   }

        //   children.add(new CoFlowLayoutConstraintData(
        //     key: key,
        //     child: pComponent,
        //     id: pComponent,
        //   ));
        // }
      });
    } else {
      _constraintMap.putIfAbsent(pComponent, () => pConstraint);

      // if (pComponent.componentModel.isVisible) {
      //   Key key =
      //       this.getKeyByComponentId(pComponent.componentModel.componentId);

      //   if (key == null) {
      //     key = this.createKey(pComponent.componentModel.componentId);
      //   }

      //   children.add(new CoFlowLayoutConstraintData(
      //     key: key,
      //     child: pComponent,
      //     id: pComponent,
      //   ));
      // }
    }
  }

  @override
  String? getConstraints(ComponentWidget comp) {
    return _constraintMap[comp];
  }

  @override
  void removeLayoutComponent(ComponentWidget pComponent) {
    if (setState != null) {
      setState!(() {
        _constraintMap.removeWhere((c, s) =>
            c.componentModel.componentId.toString() ==
            pComponent.componentModel.componentId.toString());

        // children.removeWhere((element) =>
        //     (element.child as ComponentWidget).componentModel.componentId ==
        //     pComponent.componentModel.componentId);
      });
    } else {
      _constraintMap.removeWhere((c, s) =>
          c.componentModel.componentId.toString() ==
          pComponent.componentModel.componentId.toString());

      // children.removeWhere((element) =>
      //     (element.child as ComponentWidget).componentModel.componentId ==
      //     pComponent.componentModel.componentId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomStatefulBuilder(
      dispose: () => super.setState = null,
      builder: (context, setState) {
        this.children = <CoFlowLayoutConstraintData>[];

        this._constraintMap.forEach((k, v) {
          if (k.componentModel.isVisible) {
            Key? key = this.getKeyByComponentId(k.componentModel.componentId);

            if (key == null) {
              key = this.createKey(k.componentModel.componentId);
            }

            children.add(new CoFlowLayoutConstraintData(
              key: key,
              child: k,
              id: k,
            ));
          }
        });

        super.setState = setState;

        return Container(
            child: CoFlowLayoutWidget(
          key: key,
          children: children,
          insMargin: margins,
          horizontalGap: horizontalGap,
          verticalGap: verticalGap,
          horizontalAlignment: horizontalAlignment,
          verticalAlignment: verticalAlignment,
          orientation: orientation,
          horizontalComponentAlignment: horizontalComponentAlignment,
          verticalComponentAlignment: verticalComponentAlignment,
          autoWrap: autoWrap,
        ));
      },
    );
  }
}
