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

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class FlTabHeader extends StatelessWidget {
  final TabController tabController;
  final List<Widget> tabHeaderList;
  final Function(BuildContext) postFrameCallback;

  const FlTabHeader({
    super.key,
    required this.tabHeaderList,
    required this.postFrameCallback,
    required this.tabController,
  });

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      postFrameCallback(context);
    });

    // return SingleChildScrollView(
    //   scrollDirection: Axis.horizontal,
    //   child: Row(
    //     children: tabHeaderList,
    //   ),
    // );
    return TabBar(
      controller: tabController,
      tabs: tabHeaderList,
      isScrollable: true,
    );
  }
}
