import 'dart:collection';
import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_anchor.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_constraints.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_size.dart';
import 'package:flutter_client/src/model/layout/form_layout/gaps.dart';
import 'package:flutter_client/src/model/layout/form_layout/margins.dart';
import 'package:flutter_client/src/model/layout/form_layout/form_layout_used_border.dart';
import 'package:flutter_client/util/layout/form_layout/form_layout_calculate_anchors_util.dart';
import 'package:flutter_client/util/layout/form_layout/form_layout_util.dart';

import 'i_layout.dart';
import '../model/layout/layout_data.dart';
import '../model/layout/layout_position.dart';

/// Possible Horizontal Alignments (left=0,center=1,right=2,stretch=3)
enum HorizontalAlignment { left, center, right, stretch }

/// Possible Vertical Alignments (top=0,center=1,bottom=2,stretch=3)
enum VerticalAlignment { top, center, bottom, stretch }


class FormLayout extends ILayout {

  @override
  Map<String, LayoutPosition> calculateLayout(LayoutData pParent) {

    // Needed from Outside

    /// Data of children components
    final HashMap<String, LayoutData> componentData = HashMap();

    /// LayoutData, Anchor String
    final String layoutData = "";

    /// LayoutString
    final String layout = "";

    /// Position set by Parent
    final LayoutPosition? setPosition;


    // init and derived variables

    /// Margins
    final Margins margins = Margins.fromList(marginList: layout.substring(layout.indexOf(",") +1, layout.length).split(",").sublist(0,4));
    
    /// Gaps
    final Gaps gaps = Gaps.createFromList(gapsList: layout.substring(layout.indexOf(",") +1, layout.length).split(",").sublist(4,6));

    /// Raw alignments
    final List<String> alignment = layout.substring(layout.indexOf(",") +1, layout.length).split(",").sublist(6,8);

    /// Horizontal alignment
    final HorizontalAlignment horizontalAlignment =  FormLayoutUtil.getHorizontalAlignment(alignment[0]);

    /// Vertical alignment
    final VerticalAlignment verticalAlignment = FormLayoutUtil.getVerticalAlignment(alignment[1]);

    /// Anchors
    HashMap<String, FormLayoutAnchor> anchors =  FormLayoutUtil.getAnchors(layoutData);

    /// Component constraints
    HashMap<String, FormLayoutConstraints> componentConstraints = FormLayoutUtil.getComponentConstraints(componentData, anchors);




    FormLayoutUsedBorder usedBorder = FormLayoutUsedBorder();
    FormLayoutSize preferredMinimumSize = FormLayoutSize();


    /// True, if the target dependent anchors should be calculated again.
    bool calculatedTargetDependentAnchors = false;

    calculateAnchors(pAnchors: anchors, pComponentData: componentData,pComponentConstraints: componentConstraints, pUsedBorder: usedBorder, pPreferredMinimumSize: preferredMinimumSize);


    return {};
  }

  void calculateAnchors({required HashMap<String, FormLayoutAnchor> pAnchors, required HashMap<String, LayoutData> pComponentData,
    required HashMap<String, FormLayoutConstraints> pComponentConstraints, required FormLayoutUsedBorder pUsedBorder, required FormLayoutSize pPreferredMinimumSize}) {

    FormLayoutCalculateAnchorsUtil.clearAutoSize(pAnchors: pAnchors);

    // Init autoSize Anchor position
    pAnchors.forEach((anchorName, anchor) {
      // Check if two autoSize anchors are side by side
      if(anchor.relatedAnchor != null && anchor.relatedAnchor!.autoSize){
        FormLayoutAnchor relatedAutoSizeAnchor = anchor.relatedAnchor!;
        if(relatedAutoSizeAnchor.relatedAnchor != null && !relatedAutoSizeAnchor.relatedAnchor!.autoSize){
          relatedAutoSizeAnchor.position = -anchor.position;
        }
      }
    });


    // Init autoSize Anchors
    pComponentData.forEach((componentId, component) {
      FormLayoutConstraints constraint = pComponentConstraints[componentId]!;

      FormLayoutCalculateAnchorsUtil.initAutoSizeRelative(pStartAnchor: constraint.leftAnchor, pEndAnchor: constraint.rightAnchor, pAnchors: pAnchors);
      FormLayoutCalculateAnchorsUtil.initAutoSizeRelative(pStartAnchor: constraint.rightAnchor, pEndAnchor: constraint.leftAnchor, pAnchors: pAnchors);
      FormLayoutCalculateAnchorsUtil.initAutoSizeRelative(pStartAnchor: constraint.topAnchor, pEndAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
      FormLayoutCalculateAnchorsUtil.initAutoSizeRelative(pStartAnchor: constraint.bottomAnchor, pEndAnchor: constraint.topAnchor, pAnchors: pAnchors);
    });


    // AutoSize calculations
    for(double autoSizeCount = 1; autoSizeCount > 0 && autoSizeCount < 10000000;){
      pComponentData.forEach((componentId, component) {
        //Todo LayoutData needs Visible - if(component.isVisible)
        if(true){
          FormLayoutConstraints constraint = pComponentConstraints[componentId]!;
          Size preferredSize = component.preferredSize!;
          FormLayoutCalculateAnchorsUtil.calculateAutoSize(leftTopAnchor: constraint.topAnchor, rightBottomAnchor: constraint.bottomAnchor, preferredSize: preferredSize.height, autoSizeCount: autoSizeCount, pAnchors: pAnchors);
          FormLayoutCalculateAnchorsUtil.calculateAutoSize(leftTopAnchor: constraint.leftAnchor, rightBottomAnchor: constraint.rightAnchor, preferredSize: preferredSize.height, autoSizeCount: autoSizeCount, pAnchors: pAnchors);
        }
      });

      autoSizeCount = 10000000;

      pComponentData.forEach((componentId, component) {
        FormLayoutConstraints constraint = pComponentConstraints[componentId]!;

        double count;

        count = FormLayoutCalculateAnchorsUtil.finishAutoSizeCalculation(leftTopAnchor: constraint.leftAnchor, rightBottomAnchor: constraint.rightAnchor, pAnchors: pAnchors);
        if(count > 0 && count < autoSizeCount){
          autoSizeCount = count;
        }
        count = FormLayoutCalculateAnchorsUtil.finishAutoSizeCalculation(leftTopAnchor: constraint.rightAnchor, rightBottomAnchor: constraint.leftAnchor, pAnchors: pAnchors);
        if(count > 0 && count < autoSizeCount){
          autoSizeCount = count;
        }
        count = FormLayoutCalculateAnchorsUtil.finishAutoSizeCalculation(leftTopAnchor: constraint.topAnchor, rightBottomAnchor: constraint.bottomAnchor, pAnchors: pAnchors);
        if(count > 0 && count < autoSizeCount){
          autoSizeCount = count;
        }
        count = FormLayoutCalculateAnchorsUtil.finishAutoSizeCalculation(leftTopAnchor: constraint.bottomAnchor, rightBottomAnchor: constraint.topAnchor, pAnchors: pAnchors);
        if(count > 0 && count < autoSizeCount){
          autoSizeCount = count;
        }
      });
    }

    double leftWidth = 0;
    double rightWidth = 0;
    double topHeight = 0;
    double bottomHeight = 0;


    // Calculate preferredSize
    pComponentData.forEach((componentId, component) {
      FormLayoutConstraints constraint = pComponentConstraints[componentId]!;

      Size preferredComponentSize = component.preferredSize!;
      Size minimumComponentSize = component.minSize ?? const Size(0,0);

      if(constraint.rightAnchor.getBorderAnchor().name == "l"){
        double w = constraint.rightAnchor.getAbsolutePosition();
        if(w > leftWidth){
          leftWidth = w;
        }
        pUsedBorder.leftBorderUsed = true;
      }
      if(constraint.leftAnchor.getBorderAnchor().name == "r"){
        double w = -constraint.leftAnchor.getAbsolutePosition();
        if(w > rightWidth){
          rightWidth = w;
        }
        pUsedBorder.rightBorderUsed = true;
      }
      if(constraint.bottomAnchor.getBorderAnchor().name == "t"){
        double h = constraint.bottomAnchor.getAbsolutePosition();
        if(h > topHeight){
          topHeight = h;
        }
        pUsedBorder.topBorderUsed = true;
      }
      if(constraint.topAnchor.getBorderAnchor().name == "b"){
        double h = -constraint.topAnchor.getAbsolutePosition();
        if(h > bottomHeight){
          topHeight = h;
        }
        pUsedBorder.bottomBorderUsed = true;
      }

      if(constraint.leftAnchor.getBorderAnchor().name == "l" && constraint.rightAnchor.getBorderAnchor().name == "r"){
        if(!constraint.leftAnchor.autoSize || !constraint.rightAnchor.autoSize){
          double w = constraint.leftAnchor.getAbsolutePosition() - constraint.rightAnchor.getAbsolutePosition() + preferredComponentSize.width;
          if(w > pPreferredMinimumSize.preferredWidth){
            pPreferredMinimumSize.preferredWidth = w;
          }
          w = constraint.leftAnchor.getAbsolutePosition() - constraint.rightAnchor.getAbsolutePosition() + minimumComponentSize.width;
          if(w > pPreferredMinimumSize.minimumWidth){
            pPreferredMinimumSize.minimumWidth;
          }
        }
        pUsedBorder.leftBorderUsed = true;
        pUsedBorder.rightBorderUsed = true;
      }
      if(constraint.topAnchor.getBorderAnchor().name == "t" && constraint.bottomAnchor.getBorderAnchor().name == "b"){
        if(!constraint.topAnchor.autoSize || !constraint.bottomAnchor.autoSize){
          double h = constraint.topAnchor.getAbsolutePosition() - constraint.bottomAnchor.getAbsolutePosition() + preferredComponentSize.height;
          if(h > pPreferredMinimumSize.preferredHeight){
            pPreferredMinimumSize.preferredHeight = h;
          }
          h = constraint.topAnchor.getAbsolutePosition() - constraint.bottomAnchor.getAbsolutePosition() + minimumComponentSize.height;
          if(h > pPreferredMinimumSize.minimumHeight){
            pPreferredMinimumSize.minimumHeight = h;
          }
        }
        pUsedBorder.topBorderUsed = true;
        pUsedBorder.bottomBorderUsed = true;
      }
    });

    

  }



  @override
  ILayout clone() {
    // TODO: implement clone
    throw UnimplementedError();
  }
}
