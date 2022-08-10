// import 'package:flutter/widgets.dart';
// import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// import '../../../mixin/config_service_mixin.dart';
// import '../../../mixin/ui_service_mixin.dart';
// import '../../../util/image/image_loader.dart';
// import '../../../util/parse_util.dart';
// import '../../model/command/api/device_status_command.dart';
// import '../../util/misc/debouncer.dart';
// import '../drawer/drawer_menu.dart';

// /// Screen used to show workScreens either custom or from the server,
// /// will send a [DeviceStatusCommand] on open to account for
// /// custom header/footer
// class WorkScreenBody extends StatelessWidget with UiServiceGetterMixin, ConfigServiceGetterMixin {
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   // Class members
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//   /// Debounce re-layouts if keyboard opens.
//   final Debounce debounce = Debounce(delay: const Duration(milliseconds: 500));

//   FocusNode? currentObjectFocused;

//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   // Initialization
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//   WorkScreenBody({
//     Key? key,
//   }) : super(key: key);

//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
//   // Overridden methods
//   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

//   @override
//   Widget build(BuildContext context) {
//     Color? backgroundColor = ParseUtil.parseHexColor(getConfigService().getAppStyle()?['desktop.color']);
//     String? backgroundImageString = getConfigService().getAppStyle()?['desktop.icon'];

//     final viewInsets = EdgeInsets.fromWindowPadding(
//       WidgetsBinding.instance!.window.viewInsets,
//       WidgetsBinding.instance!.window.devicePixelRatio,
//     );

//     var mediaQuery = MediaQuery.of(context);

//     mediaQuery.vi

//     Widget screenWidget = widget.screenWidget;
//     if (!widget.isCustomScreen) {
//       // debounce to not re-layout multiple times when opening the keyboard
//       debounce.call(() {
//         _setScreenSize(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
//         _sendDeviceStatus(pWidth: constraints.maxWidth, pHeight: constraints.maxHeight + viewInsets.bottom);
//       });
//     } else {
//       // Wrap custom screen in Positioned
//       screenWidget = Positioned(
//         top: 0,
//         left: 0,
//         right: 0,
//         bottom: 0,
//         child: screenWidget,
//       );
//     }
//     return Stack(
//       children: [
//         SingleChildScrollView(
//           physics: viewInsets.bottom > 0 ? const ScrollPhysics() : const NeverScrollableScrollPhysics(),
//           child: Stack(
//             children: [
//               Container(
//                 height: constraints.maxHeight + viewInsets.bottom,
//                 width: constraints.maxWidth,
//                 child: backgroundImageString != null
//                     ? ImageLoader.loadImage(
//                         backgroundImageString,
//                         fit: BoxFit.scaleDown,
//                       )
//                     : null,
//                 color: backgroundColor,
//               ),
//               screenWidget
//             ],
//           ),
//         ),
//       ],
//     );

//     return GestureDetector(
//       onTap: () {
//         FocusManager.instance.primaryFocus?.unfocus();
//       },
//       child: Scaffold(
//         resizeToAvoidBottomInset: false,
//         appBar: AppBar(
//           leading: Center(
//             child: InkWell(
//               onTap: () => _onBackTab(context),
//               onDoubleTap: () => _onDoubleTab(context),
//               child: CircleAvatar(
//                 foregroundColor: Theme.of(context).colorScheme.onPrimary,
//                 backgroundColor: Theme.of(context).primaryColor,
//                 child: const FaIcon(FontAwesomeIcons.arrowLeft),
//               ),
//             ),
//           ),
//           title: Text(widget.screenTitle),
//           actions: [
//             Builder(
//               builder: (context) => IconButton(
//                 onPressed: () => Scaffold.of(context).openEndDrawer(),
//                 icon: const FaIcon(FontAwesomeIcons.ellipsisV),
//               ),
//             ),
//           ],
//         ),
//         endDrawerEnableOpenDragGesture: false,
//         endDrawer: const DrawerMenu(),
//         body: Scaffold(
//           appBar: widget.header,
//           bottomNavigationBar: widget.footer,
//           backgroundColor: Colors.transparent,
//           body: LayoutBuilder(
//             builder: (context, constraints) {},
//           ),
//         ),
//       ),
//     );
//   }
// }
