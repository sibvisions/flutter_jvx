/*
 * Copyright 2024 SIB Visions GmbH
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
import 'package:flutter_map/flutter_map.dart';

class FlutterMapZoomButtons extends StatelessWidget {
    final double minZoom;
    final double maxZoom;
    final bool mini;
    final double padding;
    final Alignment alignment;
    final Color? zoomInColor;
    final Color? zoomInColorIcon;
    final Color? zoomOutColor;
    final Color? zoomOutColorIcon;
    final IconData zoomInIcon;
    final IconData zoomOutIcon;

    const FlutterMapZoomButtons({
        super.key,
        this.minZoom = 1,
        this.maxZoom = 19,
        this.mini = true,
        this.padding = 2.0,
        this.alignment = Alignment.topRight,
        this.zoomInColor,
        this.zoomInColorIcon,
        this.zoomInIcon = Icons.add,
        this.zoomOutColor,
        this.zoomOutColorIcon,
        this.zoomOutIcon = Icons.remove,
    });

    @override
    Widget build(BuildContext context) {
        final controller = MapController.of(context);
        final camera = MapCamera.of(context);
        final theme = Theme.of(context);

        return SafeArea(child: Align(
            alignment: alignment,
            child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                    Padding(
                        padding:
                        EdgeInsets.only(left: padding, top: padding, right: padding),
                        child: FloatingActionButton(
                            heroTag: 'zoomInButton',
                            mini: mini,
                            backgroundColor: zoomInColor ?? theme.primaryColor,
                            onPressed: () {
                                final zoom = min(camera.zoom + 1, maxZoom);
                                controller.move(camera.center, zoom);
                            },
                            child: Icon(zoomInIcon,
                                color: zoomInColorIcon ?? theme.iconTheme.color),
                        ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(padding),
                        child: FloatingActionButton(
                            heroTag: 'zoomOutButton',
                            mini: mini,
                            backgroundColor: zoomOutColor ?? theme.primaryColor,
                            onPressed: () {
                                final zoom = max(camera.zoom - 1, minZoom);
                                controller.move(camera.center, zoom);
                            },
                            child: Icon(zoomOutIcon,
                                color: zoomOutColorIcon ?? theme.iconTheme.color),
                        ),
                    ),
                ],
            ),
        )
        );
    }
}