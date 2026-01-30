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

import 'package:card_loading/card_loading.dart';
import 'package:flutter/material.dart';

import '../../../flutter_jvx.dart';

class SkeletonMenu extends StatelessWidget {
  const SkeletonMenu({super.key});

  @override
  Widget build(BuildContext context) {
    const Duration animationDuration = Duration(milliseconds: 750 + 550);
    const Duration animationDurationTwo = Duration(milliseconds: 450 + 550);

    final CardLoadingTheme cardLoadingTheme = JVxColors.isLightTheme(context)
          ? CardLoadingTheme.defaultTheme
          : const CardLoadingTheme(colorOne: Color(0x40E5E5E5), colorTwo: Color(0x40F0F0F0));

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 20,
      mainAxisSpacing: 10,
      children: List.generate(100, (index) {
        return Center(
          child: CardLoading(
              cardLoadingTheme: cardLoadingTheme,
              height: double.infinity,
              animationDuration: animationDuration,
              animationDurationTwo: animationDurationTwo,
              borderRadius: const BorderRadius.all(Radius.circular(JVxColors.BORDER_RADIUS)),
              margin: const EdgeInsets.only(bottom: 10),
            )
          );
        })
      );
  }
}
