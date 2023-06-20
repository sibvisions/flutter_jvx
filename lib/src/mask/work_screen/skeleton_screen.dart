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

class SkeletonScreen extends StatelessWidget {
  const SkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Duration animationDuration = Duration(milliseconds: 750 + 550);
    const Duration animationDurationTwo = Duration(milliseconds: 450 + 550);
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CardLoading(
          height: 25,
          width: 100,
          animationDuration: animationDuration,
          animationDurationTwo: animationDurationTwo,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          margin: EdgeInsets.only(bottom: 10),
        ),
        CardLoading(
          height: 50,
          animationDuration: animationDuration,
          animationDurationTwo: animationDurationTwo,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          margin: EdgeInsets.only(bottom: 10),
        ),
        Align(
          alignment: Alignment.centerRight,
          child: CardLoading(
            height: 50,
            width: 120,
            animationDuration: animationDuration,
            animationDurationTwo: animationDurationTwo,
            borderRadius: BorderRadius.all(Radius.circular(5)),
            margin: EdgeInsets.only(bottom: 10),
          ),
        ),
        SizedBox(
          height: 50,
        ),
        CardLoading(
          height: 25,
          width: 100,
          animationDuration: animationDuration,
          animationDurationTwo: animationDurationTwo,
          borderRadius: BorderRadius.all(Radius.circular(5)),
          margin: EdgeInsets.only(bottom: 10),
        ),
        Expanded(
          child: CardLoading(
            height: double.infinity,
            animationDuration: animationDuration,
            animationDurationTwo: animationDurationTwo,
            borderRadius: BorderRadius.all(Radius.circular(5)),
          ),
        ),
      ],
    );
  }
}
