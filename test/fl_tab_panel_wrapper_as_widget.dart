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

import 'dart:async';

import 'package:flutter/material.dart';

import '../lib/src/model/command/layout/preferred_size_command.dart';
import '../lib/src/model/component/fl_component_model.dart';
import '../lib/src/model/layout/layout_data.dart';
import '../lib/src/service/command/i_command_service.dart';

enum TabPlacements { WRAP, TOP, LEFT, BOTTOM, RIGHT }

// THIS IS A SIMPLE TEST COMPONENT
//
// Use it like a default StatefulWidget (with size constraints)

class FlTabPanelWrapperAsWidget extends StatefulWidget {
    final FlTabPanelModel model;

    const FlTabPanelWrapperAsWidget({super.key,
      required this.model});

    @override
    State<FlTabPanelWrapperAsWidget> createState() => _FlTabPanelWrapperAsWidgetState();
}

class _FlTabPanelWrapperAsWidgetState extends State<FlTabPanelWrapperAsWidget> with TickerProviderStateMixin {
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Class members
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    final Map<String, Key> _mapKey = {};

    late List<Tab> tabs;
    late List<Tab> tabsInit;
    late List<Widget> tabContent;
    late List<Widget> tabContentInit;

    late TabController _tabController;
    late PageController _pageController;

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Initialization
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    _FlTabPanelWrapperAsWidgetState() : super();

    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    // Overridden methods
    //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    @override
    void initState() {
        super.initState();

        LayoutData layoutData = LayoutData(
            id: widget.model.parent!,
            name: widget.model.name,
            parentId: widget.model.parent,
            constraints: widget.model.constraints,
            bounds: widget.model.bounds,
            preferredSize: Size(500, 600),
            minSize: Size(500, 600),
            maxSize: widget.model.maximumSize,
            indexOf: widget.model.indexOf,
            heightConstrains: {},
            widthConstrains: {},
        );
        ICommandService().sendCommand(PreferredSizeCommand(layoutData: layoutData, reason: "Send size"));

        tabs = [];
        tabContent = [];

        for (int i = 0; i < 6; i++) {
            final stableKey = _mapKey.putIfAbsent("tab: $i", () => ValueKey("tab: $i"));

            tabs.add(Tab(
                key: stableKey,
                child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                        Text("Tab $i"),
                        const SizedBox(width: 8),
                        InkWell(
                            onTap: () => removeTab(i),
                            child: const Icon(Icons.close, size: 16),
                        )

                    ],
                ),
            )
            );
        }

        for (int i = 0; i < 6; i++) {
            final stableKey = _mapKey.putIfAbsent("content: $i", () => PageStorageKey("content: $i"));
            tabContent.add(MyWidget(key: stableKey));
        }

        tabsInit = List<Tab>.from(tabs);
        tabContentInit = List<Widget>.from(tabContent);

        _tabController = TabController(length: tabContent.length, vsync: this, initialIndex: 0);

        _pageController = PageController();

        /*
        timer = Timer.periodic(const Duration(seconds: 10), (_) {
//            print("Neuer Controller");

            try {
//                _tabController = TabController(length: tabContent.length, vsync: this, initialIndex: _tabController.index);
            }
            catch (error) {
                print(error);
            }

//            print("Neuer Controller");

            setState(() {
            });
        });
         */
    }

Timer? timer;

    @override
    void dispose() {
        timer?.cancel();

        _tabController.dispose();
        _pageController.dispose();

        super.dispose();
    }

bool _isManualTap = false;

    @override
    Widget build(BuildContext context) {
        return Wrap(children: [
            TabBar(controller: _tabController,
                isScrollable: true,
                tabAlignment: TabAlignment.start,
                tabs: tabs,
                onTap: (index) async {
                    if (_tabController.index == index) {
//                        return;
                    }

                    _isManualTap = true;
                    try {
                        _tabController.animateTo(index);

                        int currentPage = _pageController.page!.round();

                        if ((index - currentPage).abs() > 1) {
                            int neighborindex = index > currentPage ? index - 1 : index + 1;
                            _pageController.jumpToPage(neighborindex);
                            await WidgetsBinding.instance.endOfFrame;
                        }

                        unawaited(_pageController.animateToPage(index, duration: kTabScrollDuration, curve: Curves.easeInOut));
                    }
                    finally {
                        _isManualTap = false;
                    }
                },
            ),
/*
            Container(
                width: 400,
                height: 600,
                child: GestureDetector(
                    child: PageStorage(
                        bucket: _bucket,
                            child: TabBarView(
                            //physics: const NeverScrollableScrollPhysics(),
                            controller: _tabController,
                            children: tabContent.mapIndexed((index, element) => MyWidget(key: PageStorageKey("content: ${tabContentInit.indexOf(element)}"))).toList()
                            )
                    )
                )
            )

 */

        SizedBox(
            width: 400,
            height: 600,
            child: PageView.builder(controller: _pageController,
                //physics: BouncingScrollPhysics(),
                allowImplicitScrolling: true,
                itemCount: tabContent.length,
                findChildIndexCallback: (Key key) {
                  for (int i = 0; i < tabContent.length; i++) {
                      if (tabContent[i].key == key) {
                          return i;
                      }
                  }

                  return -1;
                },
                onPageChanged: (index) {
                    print("animate to: $index ${_tabController.indexIsChanging}");

                    if (!_isManualTap) {
                        _tabController.animateTo(index);
                    }
                },
                itemBuilder: (context, index) {
                print("Get: $index");
                  return tabContent[index];
                },
            )
        )


        ]);
    }

    void removeTab(int index) {
        timer?.cancel();

        int oldLength = tabs.length;

        print("Old length: $oldLength");
/*
        tabs.clear();
        for (int i = 0, j = 0; i < oldLength; i++, j++) {
            if (i != index) {
                final stableKey = _mapKey.putIfAbsent("tab: $i", () => ValueKey("tab: $i");

                tabs.add(Tab(
                    key: stableKey,
                    child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                            Text("Tab $j"),
                            const SizedBox(width: 8),
                            InkWell(
                                onTap: () => removeTab(j),
                                child: const Icon(Icons.close, size: 16),
                            )

                        ],
                    ),
                )
                );
            }
        }

        for (int i = 0, j=0; i < oldLength; i++, j++) {
            if (i != index) {
                final stableKey = _mapKey.putIfAbsent("content: $i", () => ValueKey("content: $i"));
                tabContent.add(MyWidget(key: stableKey));
            }
        }
*/

tabs.remove(tabsInit[index]);
tabContent.remove(tabContentInit[index]);

        setState(() {
            _tabController = TabController(length: tabContent.length, vsync: this, initialIndex: _tabController.index - 1);
        });
    }
}

class MyWidget extends StatefulWidget {
    const MyWidget({super.key});

    @override
    State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> with AutomaticKeepAliveClientMixin {
    int counter = 0;

    @override
    bool get wantKeepAlive => true;

    @override
    @mustCallSuper
    Widget build(BuildContext context) {
        super.build(context);

        return Stack(children: [Column(
            mainAxisSize: MainAxisSize.min,
            children: [
                Text('Counter: $counter'),
                const SizedBox(height: 8),
                ElevatedButton(
                    onPressed: () {
                        setState(() {
                            counter++;
                        });
                    },
                    child: const Text('Increase'),
                ),
            ],
        )]);
    }
}

