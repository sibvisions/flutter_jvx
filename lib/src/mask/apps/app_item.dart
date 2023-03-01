/*
 * Copyright 2023 SIB Visions GmbH
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
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'app_image.dart';

class AppItem extends StatelessWidget {
  const AppItem({
    super.key,
    required this.app,
    this.onTap,
    this.onLongPress,
    this.image,
    this.icon,
    this.isDefault = false,
    this.locked = false,
  });

  final String app;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final ImageProvider? image;
  final IconData? icon;
  final bool isDefault;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    const double borderRadius = 20;
    return Container(
      foregroundDecoration: onTap == null
          ? const BoxDecoration(
              color: Colors.grey,
              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
              backgroundBlendMode: BlendMode.darken,
            )
          : null,
      child: Material(
        type: MaterialType.card,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: 5,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  flex: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: AppImage(
                        image: image,
                        icon: icon,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Material(
                    color:
                        Theme.of(context).brightness == Brightness.light ? Colors.grey.shade200 : Colors.grey.shade700,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(borderRadius),
                      bottomRight: Radius.circular(borderRadius),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                        child: Text(
                          app,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            height: 1.2,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(borderRadius),
                  // NoSplash.splashFactory doesn't work
                  highlightColor: onTap != null ? null : Colors.transparent,
                  splashColor: onTap != null ? null : Colors.transparent,
                  onTap: onTap,
                  onLongPress: onLongPress,
                ),
              ),
            ),
            if (locked)
              Positioned(
                top: 10,
                left: 10,
                child: Icon(
                  Icons.lock,
                  size: 18,
                  color: Theme.of(context).colorScheme.onSurface,
                ),
              ),
            if (isDefault)
              Positioned(
                top: -9,
                right: -9,
                child: Material(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 2,
                  borderRadius: BorderRadius.circular(32),
                  child: Padding(
                    padding: const EdgeInsets.all(6.0),
                    child: FaIcon(
                      FontAwesomeIcons.check,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 18,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
