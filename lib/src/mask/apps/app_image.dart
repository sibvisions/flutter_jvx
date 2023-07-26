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

import 'package:avatars/avatars.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../flutter_ui.dart';
import '../../util/image/image_loader.dart';
import '../../util/jvx_colors.dart';

class AppImage extends StatelessWidget {
  const AppImage({
    super.key,
    this.name,
    this.image,
    this.icon,
    this.fit = BoxFit.scaleDown,
  });

  final String? name;
  final ImageProvider<Object>? image;
  final IconData? icon;
  final BoxFit fit;

  static String _normalizeName(String name) => name.replaceAll(RegExp("[^a-zA-Z\\d\\s]"), "");

  @override
  Widget build(BuildContext context) {
    const double avatarRadius = 50;

    return IconTheme.merge(
      // Darken color to not get overwritten by a grey ColorFilter/foregroundDecoration.
      data: IconThemeData(color: JVxColors.darken(Colors.grey)),
      child: Stack(
        children: [
          if (image != null)
            Positioned.fill(
              child: Image(
                image: image!,
                fit: fit,
                loadingBuilder: ImageLoader.createImageLoadingBuilder(),
                errorBuilder: (context, error, stackTrace) {
                  FlutterUI.logUI.e("Failed to load app image", error: error, stackTrace: stackTrace);
                  return const Center(child: FaIcon(FontAwesomeIcons.triangleExclamation, size: 40));
                },
              ),
            ),
          if (icon != null)
            Center(
              child: Icon(
                icon,
                size: 40,
              ),
            ),
          if (image == null && icon == null && (name?.isNotEmpty ?? false))
            Avatar(
              shape: AvatarShape.circle(avatarRadius),
              name: _normalizeName(name!),
              loader: const SizedBox(),
            ),
          if (image == null && icon == null && (name?.isEmpty ?? true))
            // Fallback
            Container(
              height: avatarRadius * 2,
              width: avatarRadius * 2,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(50)),
                color: Theme.of(context).colorScheme.background,
              ),
            ),
        ],
      ),
    );
  }
}
