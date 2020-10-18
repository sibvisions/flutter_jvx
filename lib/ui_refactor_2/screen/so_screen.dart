import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'i_screen.dart';

class SoScreen extends StatelessWidget implements IScreen {
  final String componentId;
  final Widget child;

  const SoScreen({Key key, this.componentId, this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(widthFactor: 1, heightFactor: 1, child: child);
  }

  @override
  bool withServer() {
    return true;
  }
}

// class SoScreen extends StatefulWidget implements IScreen {
//   final GlobalKey<SoScreenState> globalKey;
//   final String title = "OpenScreen";
//   final String componentId;
//   final List<DataBook> data = <DataBook>[];
//   final List<MetaData> metaData = <MetaData>[];
//   final Function buttonCallback;
//   final ComponentScreenWidget componentScreen;
//   final Request currentRequest;
//   final ResponseData currentResponseData;

//   final IComponentCreator componentCreator;

//   SoScreen(
//       {@required this.globalKey,
//       IComponentCreator componentCreator,
//       this.componentId,
//       this.buttonCallback,
//       this.componentScreen,
//       this.currentRequest,
//       this.currentResponseData})
//       : componentCreator = componentCreator,
//         super(key: globalKey);

//   @override
//   void update(Request request, ResponseData responseData) {
//     if (globalKey.currentState != null) {
//       globalKey.currentState.update(request, responseData);
//     }
//   }

//   @override
//   bool withServer() {
//     return true;
//   }

//   @override
//   State<StatefulWidget> createState() => SoScreenState(this.componentId,
//       this.componentCreator, this.currentRequest, this.currentResponseData);
// }

// class SoScreenState extends State<SoScreen> {
//   String componentId;
//   IComponentCreator componentCreator;
//   Request currentRequest;
//   ResponseData currentResponseData;

//   SoScreenState(this.componentId, this.componentCreator, this.currentRequest,
//       this.currentResponseData);

//   @override
//   Widget build(BuildContext context) {
//     return FractionallySizedBox(
//         widthFactor: 1,
//         heightFactor: 1,
//         child: ComponentScreenWidget(
//           componentCreator: this.componentCreator,
//           request: currentRequest,
//           responseData: currentResponseData,
//         ));
//   }

//   void update(Request request, ResponseData responseData) {
//     this.setState(() {
//       if (request != null) currentRequest = request;
//       if (responseData != null) currentResponseData = responseData;
//     });

//     // componentScreen.state?.updateData(request, responseData);
//     // if (responseData.screenGeneric != null)
//     //   componentScreen.state
//     //       ?.updateComponents(responseData.screenGeneric.changedComponents);
//   }
// }
