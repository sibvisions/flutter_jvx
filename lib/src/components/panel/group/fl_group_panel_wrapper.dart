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

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../layout/i_layout.dart';
import '../../../model/component/fl_component_model.dart';
import '../../../model/layout/alignments.dart';
import '../../../model/layout/layout_data.dart';
import '../../../model/layout/layout_position.dart';
import '../../../service/storage/i_storage_service.dart';
import '../../../util/jvx_colors.dart';
import '../../base_wrapper/base_comp_wrapper_state.dart';
import '../../base_wrapper/base_comp_wrapper_widget.dart';
import '../../base_wrapper/base_cont_wrapper_state.dart';
import '../fl_sized_panel_widget.dart';
import 'fl_group_panel_header_widget.dart';

class FlGroupPanelWrapper extends BaseCompWrapperWidget<FlGroupPanelModel> {
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Initialization
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    const FlGroupPanelWrapper({super.key, required super.model, super.offstage});

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Overridden methods
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    @override
    BaseCompWrapperState<FlComponentModel> createState() => _FlGroupPanelWrapperState();
}

class _FlGroupPanelWrapperState extends BaseContWrapperState<FlGroupPanelModel>
                                with SingleTickerProviderStateMixin{

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Class members
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    bool _layoutAfterBuild = false;

    bool _isCollapsed = false;

    bool _resizeEnabled = false;

    LayoutData? layoutDataCollapsedOld;

    late AnimationController _controller;

    final Tween<double> _heightTween = Tween<double>(begin: 0, end: 0);
    late Animation<double> _heightAnimation;

    Size? preferredSizeBeforeCollapse;
    LayoutPosition? posBeforeCollapse;

    double? _lastSentHeight;
    double? _lastAnimateToHeight;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Initialization
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _FlGroupPanelWrapperState() : super();

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Overridden methods
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    @override
    void initState() {
        super.initState();

        //we need the real size for expand -> so only cache info
        layoutDataCollapsedOld = model.layoutDataCollapsed;

        _controller = AnimationController(
            duration: const Duration(milliseconds: 300),
            vsync: this,
        );

        _heightAnimation = _heightTween.animate(
            CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
        );

        _controller.addListener(() {
            _updateHeight();
        });

        _controller.addStatusListener((status) {
            if (status == AnimationStatus.completed) {
                _resizeEnabled = false;

                if (!_isCollapsed) {
                    model.layoutDataCollapsed = null;

                    layoutData.preferredSize = preferredSizeBeforeCollapse;
                    if (posBeforeCollapse != null) {
                        layoutData.layoutPosition = posBeforeCollapse;
                    }
                }
                else {
                    model.layoutDataCollapsed = layoutData.clone();
                    model.layoutDataCollapsed!.layoutPosition?.height = _heightAnimation.value;
                }
            }
        });

        _createLayout();
        _layoutAfterBuild = true;

        buildChildren(setStateOnChange: false);
    }

    @override
    void dispose() {
        _controller.dispose();

        super.dispose();
    }

    @override
    modelUpdated() {
        _createLayout();
        super.modelUpdated();

        _layoutAfterBuild = true;

        if (!buildChildren()) {
            setState(() {});
        }
    }

    @override
    affected() {
        _layoutAfterBuild = true;

        buildChildren();
    }

    @override
    void receiveNewLayoutData(LayoutData newLayoutData, {bool repaint = true, List<LayoutData>? cache}) {
        List<LayoutData> calcCache = [];

        super.receiveNewLayoutData(newLayoutData, repaint: false, cache: cache ?? calcCache);

        bool calcLate = true;

        //restore the collapsed state if available in model
        //this is here because we need the real layoutData

        //we need the same width, because it's possible to receive multiple new layouts before size will match
        if (layoutDataCollapsedOld != null
            && newLayoutData.layoutPosition?.width == layoutDataCollapsedOld!.layoutPosition?.width) {

            if (layoutDataCollapsedOld?.layoutPosition != null) {
                //restore info
                preferredSizeBeforeCollapse = layoutData.preferredSize;
                posBeforeCollapse = layoutData.layoutPosition?.clone();

                layoutData = layoutDataCollapsedOld!;

                _isCollapsed = true;
                _resizeEnabled = true;

                calcLate = false;

                _animateTo(layoutDataCollapsedOld!.layoutPosition!.height, immediate: true);
            }

            model.layoutDataCollapsed = null;
            layoutDataCollapsedOld = null;
        }

        if (calcLate && calcCache.isNotEmpty) {
            sendCalcSize(layoutData: calcCache.first, reason: "Component has been constrained");
        }

        if (repaint) {
            setState(() {});
        }
    }

    @override
    Widget build(BuildContext context) {
        Widget w;

        if (widget.offstage) {
            w = Offstage();
        }
        else if (model.isFlatStyle) {
            w = _buildFlat(context);
        } else {
            w = _buildModern(context);
        }

        return wrapWidget(context, w);
    }

    @override
    Widget wrapWidget(BuildContext context, Widget child, [bool outlineBadge = true]) {
        Widget w;

        if (widget.offstage) {
            return super.wrapWidget(context, child, outlineBadge);
        } else {
            w = wrapWithSemantic(
                wrapWithDesignListener(
                    outlineBadge && child is! Badge ? wrapWithBadge(context, child) : child
                ),
            );

            if (!_resizeEnabled && !_isCollapsed) {
                return Positioned(
                    top: getTopForPositioned(context),
                    left: getLeftForPositioned(context),
                    width: getWidthForPositioned(context),
                    height: getHeightForPositioned(context),
                    child: child,
                );
            }
            else {
                return AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                        return Positioned(
                            top: getTopForPositioned(context),
                            left: getLeftForPositioned(context),
                            width: getWidthForPositioned(context),
                            height: _heightAnimation.value,
                            child: child!,
                        );
                    },
                    child: w
                );
            }
        }
    }

    @override
    void postFrameCallback(BuildContext context) {
        if (!mounted) {
            return;
        }

        // This is the context of the header, not of this panel!
        double groupHeaderHeight = calculateSize(context).height;

        if (groupHeaderHeight != layoutData.insets.top) {
            layoutData.insets = EdgeInsets.only(top: groupHeaderHeight);
            _layoutAfterBuild = true;
        }

        if (_layoutAfterBuild) {
            _layoutAfterBuild = false;
            registerParent();
        }

        if (!_resizeEnabled && !_isCollapsed && layoutData.layoutPosition != null)  {
            _animateTo(layoutData.layoutPosition!.height);
        }
    }

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // User-defined methods
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    Widget _buildFlat(BuildContext context) {
        return Column(
            verticalDirection: verticalDirection,
            children: [
                FlGroupPanelHeaderWidget(model: model, postFrameCallback: postFrameCallback),
                const Divider(
                    color: JVxColors.COMPONENT_BORDER,
                    height: 0.0,
                    thickness: 1.0,
                ),
                FlSizedPanelWidget(
                    model: model,
                    width: widthOfGroupPanel,
                    height: heightOfGroupPanel,
                    children: childWidgets,
                ),
            ],
        );
    }

    Widget _buildModern(BuildContext context) {
        double groupHeaderHeight = layoutData.insets.top;

        List<BoxShadow> shadows = [];
        if (!model.isBorderHidden) {
            shadows = [
                const BoxShadow(offset: Offset(0.0, 3.0), blurRadius: 3.0, spreadRadius: -1.0, color: Color(0x33000000)),
                const BoxShadow(offset: Offset(0.0, 3.0), blurRadius: 4.0, spreadRadius: 1.0, color: Color(0x24000000)),
                const BoxShadow(offset: Offset(0.0, 1.0), blurRadius: 8.0, spreadRadius: 1.0, color: Color(0x1F000000)),
            ];
        }

        model.verticalAlignment = VerticalAlignment.BOTTOM;

        EdgeInsets paddings;
        if (model.verticalAlignment == VerticalAlignment.BOTTOM) {
            paddings = EdgeInsets.only(top: groupHeaderHeight / 2);
        } else {
            paddings = EdgeInsets.only(bottom: groupHeaderHeight / 2);
        }

        return LayoutBuilder(builder: (context, constraints) {

          Widget contentPanel = FlSizedPanelWidget(
                model: model,
                width: widthOfGroupPanel,
                height: max(0, constraints.maxHeight - groupHeaderHeight),
                decoration: BoxDecoration(
                    color: model.background ?? Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.only(bottomLeft: Radius.circular(4), bottomRight: Radius.circular(4)),
                ),
                children: childWidgets
            );

          if (_resizeEnabled || !_isCollapsed) {
              contentPanel = SingleChildScrollView(
                physics: NeverScrollableScrollPhysics(),
                clipBehavior: Clip.hardEdge,
                child: contentPanel,
              );
          }

          return Stack(
              children: [
                  Positioned(
                      top: model.verticalAlignment == VerticalAlignment.BOTTOM ? groupHeaderHeight / 2 : null,
                      bottom: model.verticalAlignment == VerticalAlignment.BOTTOM ? null : groupHeaderHeight / 2,
                      child: DecoratedBox(
                          decoration: BoxDecoration(
                              color: model.background ?? Theme.of(context).colorScheme.surface,
                              borderRadius: BorderRadius.circular(4.0),
                              boxShadow: shadows,
                          ),
                          child: Padding(
                              padding: paddings,
                              child: contentPanel
                          ),
                      )
                  ),
                  Positioned(
                      top: model.verticalAlignment == VerticalAlignment.BOTTOM ? 0 : null,
                      bottom: model.verticalAlignment == VerticalAlignment.BOTTOM ? null : 0,
                      left: 0,
                      right: 0,
                      child: GestureDetector(
                          onDoubleTap: () {
                              if (model.canCollapse && !_resizeEnabled) {
                                  if (!_isCollapsed) {
                                      preferredSizeBeforeCollapse = layoutData.preferredSize;
                                      posBeforeCollapse = layoutData.layoutPosition?.clone();
                                  }

                                  _isCollapsed = !_isCollapsed;

                                  double animateTo = _isCollapsed ?
                                  layoutData.insets.top + 10.0 :
                                  posBeforeCollapse != null ? posBeforeCollapse!.height : getHeightForPositioned(context);

                                  _resizeEnabled = true;

                                  _animateTo(animateTo);
                              }
                          },
                          child: FlGroupPanelHeaderWidget(
                              model: model,
                              postFrameCallback: postFrameCallback,
                          )
                      ),
                  )
              ],
          );
        });
    }

    void _createLayout() {
        layoutData.layout = ILayout.getLayout(model);
        layoutData.children =
            IStorageService().getAllComponentsBelowById(parentId: model.id, recursively: false).map((e) => e.id).toList();
    }

    void _animateTo(double height, {bool immediate = false}) {
        double height_ = (height * 100).round() / 100;

        if (_lastAnimateToHeight != height_) {
            _controller.reset();

            _heightTween.begin = _lastAnimateToHeight ?? 0;
            _heightTween.end = height_;

            _lastAnimateToHeight = height_;

            if (immediate) {
                _heightTween.begin = _heightTween.end;
            }

            _controller.forward();
        }
    }

    /// Updates the layout height
    void _updateHeight() {
        if (_resizeEnabled) {
            double height_ = (_heightAnimation.value * 100).round() / 100;

            if (height_ == 0 || _lastSentHeight == height_) {
                return;
            }

            _lastSentHeight = height_;

            SchedulerBinding.instance.addPostFrameCallback((_) {
                if (!mounted) {
                    return;
                }

                Size newSize = Size(layoutData.layoutPosition?.width ?? 0, height_);

                LayoutData data = layoutData.clone();
                data.preferredSize = newSize;
                data.layoutPosition?.height = newSize.height;
                data.lastCalculatedSize = newSize;
                data.calculatedSize = newSize;

                sendCalcSize(layoutData: data, reason: "Update group panel height");
            });
        }
    }

    double get widthOfGroupPanel {
        if (layoutData.hasPosition) {
            return layoutData.layoutPosition!.width;
        }

        return 0.0;
    }

    double get heightOfGroupPanel {
        if (_resizeEnabled) {
            return _heightAnimation.value - layoutData.insets.vertical;
        }

        if (layoutData.hasPosition) {
            return layoutData.layoutPosition!.height - layoutData.insets.vertical;
        }

        return 0.0;
    }

    VerticalDirection get verticalDirection {
        if (model.verticalAlignment == VerticalAlignment.BOTTOM) {
            return VerticalDirection.up;
        } else {
            return VerticalDirection.down;
        }
    }
}
