// import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:flutter/material.dart';
//
// import 'notification_controller.dart';
//
// class Example extends StatefulWidget {
//   const Example({super.key});
//
//   static final GlobalKey<NavigatorState> navigatorKey =
//       GlobalKey<NavigatorState>();
//
//   @override
//   State<StatefulWidget> createState() => _ExampleState();
// }
//
// class _ExampleState extends State<Example> {
//   static const String routeHome = '/', routeNotification = '/notification-page';
//
//   @override
//   void initState() {
//     NotificationController.startListeningNotificationEvents();
//     super.initState();
//   }
//
//   List<Route<dynamic>> onGenerateInitialRoutes(String initialRouteName) {
//     List<Route<dynamic>> pageStack = [];
//     pageStack.add(
//       MaterialPageRoute(
//         builder: (_) => const MyHomePage(
//           title: 'Awesome Notifications Example App',
//         ),
//       ),
//     );
//     if (initialRouteName == routeNotification &&
//         NotificationController.initialAction != null) {
//       pageStack.add(MaterialPageRoute(
//           builder: (_) => NotificationPage(
//               receivedAction: NotificationController.initialAction!)));
//     }
//     return pageStack;
//   }
//
//   Route<dynamic>? onGenerateRoute(RouteSettings settings) {
//     switch (settings.name) {
//       case routeHome:
//         return MaterialPageRoute(
//           builder: (_) =>
//               const MyHomePage(title: 'Awesome Notifications Example App'),
//         );
//
//       case routeNotification:
//         ReceivedAction receivedAction = settings.arguments as ReceivedAction;
//         return MaterialPageRoute(
//             builder: (_) => NotificationPage(receivedAction: receivedAction));
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Awesome Notifications - Simple Example',
//       navigatorKey: Example.navigatorKey,
//       onGenerateInitialRoutes: onGenerateInitialRoutes,
//       onGenerateRoute: onGenerateRoute,
//       theme: ThemeData(
//         primarySwatch: Colors.deepPurple,
//       ),
//     );
//   }
// }
//
// ///  *********************************************
// ///     HOME PAGE
// ///  *********************************************
// ///
// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});
//
//   final String title;
//
//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const <Widget>[
//             Text(
//               'Push the buttons below to create new notifications',
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.all(20.0),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const SizedBox(width: 20),
//             FloatingActionButton(
//               heroTag: '1',
//               onPressed: () => NotificationController.createNewNotification(),
//               tooltip: 'Create New notification',
//               child: const Icon(Icons.outgoing_mail),
//             ),
//             const SizedBox(width: 10),
//             FloatingActionButton(
//               heroTag: '2',
//               onPressed: () => NotificationController.scheduleNewNotification(),
//               tooltip: 'Schedule New notification',
//               child: const Icon(Icons.access_time_outlined),
//             ),
//             const SizedBox(width: 10),
//             FloatingActionButton(
//               heroTag: '3',
//               onPressed: () => NotificationController.resetBadgeCounter(),
//               tooltip: 'Reset badge counter',
//               child: const Icon(Icons.exposure_zero),
//             ),
//             const SizedBox(width: 10),
//             FloatingActionButton(
//               heroTag: '4',
//               onPressed: () => NotificationController.cancelNotifications(),
//               tooltip: 'Cancel all notifications',
//               child: const Icon(Icons.delete_forever),
//             ),
//           ],
//         ),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }
//
// ///  *********************************************
// ///     NOTIFICATION PAGE
// ///  *********************************************
// ///
// class NotificationPage extends StatelessWidget {
//   const NotificationPage({Key? key, required this.receivedAction})
//       : super(key: key);
//
//   final ReceivedAction receivedAction;
//
//   @override
//   Widget build(BuildContext context) {
//     bool hasLargeIcon = receivedAction.largeIconImage != null;
//     bool hasBigPicture = receivedAction.bigPictureImage != null;
//     double bigPictureSize = MediaQuery.of(context).size.height * .4;
//     double largeIconSize =
//         MediaQuery.of(context).size.height * (hasBigPicture ? .12 : .2);
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(receivedAction.title ?? receivedAction.body ?? ''),
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.zero,
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.start,
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//                 height:
//                     hasBigPicture ? bigPictureSize + 40 : largeIconSize + 60,
//                 child: hasBigPicture
//                     ? Stack(
//                         children: [
//                           if (hasBigPicture)
//                             FadeInImage(
//                               placeholder: const NetworkImage(
//                                   'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
//                               //AssetImage('assets/images/placeholder.gif'),
//                               height: bigPictureSize,
//                               width: MediaQuery.of(context).size.width,
//                               image: receivedAction.bigPictureImage!,
//                               fit: BoxFit.cover,
//                             ),
//                           if (hasLargeIcon)
//                             Positioned(
//                               bottom: 15,
//                               left: 20,
//                               child: ClipRRect(
//                                 borderRadius: BorderRadius.all(
//                                     Radius.circular(largeIconSize)),
//                                 child: FadeInImage(
//                                   placeholder: const NetworkImage(
//                                       'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
//                                   //AssetImage('assets/images/placeholder.gif'),
//                                   height: largeIconSize,
//                                   width: largeIconSize,
//                                   image: receivedAction.largeIconImage!,
//                                   fit: BoxFit.cover,
//                                 ),
//                               ),
//                             )
//                         ],
//                       )
//                     : Center(
//                         child: ClipRRect(
//                           borderRadius:
//                               BorderRadius.all(Radius.circular(largeIconSize)),
//                           child: FadeInImage(
//                             placeholder: const NetworkImage(
//                                 'https://cdn.syncfusion.com/content/images/common/placeholder.gif'),
//                             //AssetImage('assets/images/placeholder.gif'),
//                             height: largeIconSize,
//                             width: largeIconSize,
//                             image: receivedAction.largeIconImage!,
//                             fit: BoxFit.cover,
//                           ),
//                         ),
//                       )),
//             Padding(
//               padding: const EdgeInsets.only(bottom: 20.0, left: 20, right: 20),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   RichText(
//                       text: TextSpan(children: [
//                     if (receivedAction.title?.isNotEmpty ?? false)
//                       TextSpan(
//                         text: receivedAction.title!,
//                         style: Theme.of(context).textTheme.titleLarge,
//                       ),
//                     if ((receivedAction.title?.isNotEmpty ?? false) &&
//                         (receivedAction.body?.isNotEmpty ?? false))
//                       TextSpan(
//                         text: '\n\n',
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                     if (receivedAction.body?.isNotEmpty ?? false)
//                       TextSpan(
//                         text: receivedAction.body!,
//                         style: Theme.of(context).textTheme.bodyMedium,
//                       ),
//                   ]))
//                 ],
//               ),
//             ),
//             Container(
//               color: Colors.black12,
//               padding: const EdgeInsets.all(20),
//               width: MediaQuery.of(context).size.width,
//               child: Text(receivedAction.toString()),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


// class Bar extends StatelessWidget {
//   final double width;
//   final double height;
//   final Color color;
//   final BorderRadiusGeometry borderRadius;
//
//   const Bar({
//     Key? key,
//     required this.width,
//     required this.height,
//     this.color = Colors.white,
//     required this.borderRadius,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: width,
//       height: height,
//       child: DecoratedBox(
//         decoration: BoxDecoration(
//           shape: BoxShape.rectangle,
//           color: color,
//           borderRadius: borderRadius,
//         ),
//       ),
//     );
//   }
// }
//
// class BarMusicLoading extends StatefulWidget {
//   final double width;
//   final double height;
//   final Color color;
//   final BorderRadiusGeometry borderRadius;
//   final Duration duration;
//   final Curve curve;
//
//   const BarMusicLoading(
//       {Key? key,
//         this.width = 3.0,
//         this.height = 40.0,
//         this.color = Colors.white,
//         this.borderRadius = const BorderRadius.only(
//             topLeft: Radius.circular(3), topRight: Radius.circular(3)),
//         this.duration = const Duration(milliseconds: 3000),
//         this.curve = Curves.easeInOut})
//       : super(key: key);
//
//   @override
//   State createState() => _BarMusicLoadingState();
// }
//
// class _BarMusicLoadingState extends State<BarMusicLoading>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//
//   late Animation _animation, _animation1, _animation2, _animation3;
//   List values = [
//     [0.0, 0.7, 0.4, 0.05, 0.95, 0.3, 0.9, 0.4, 0.15, 0.18, 0.75, 0.01],
//     [0.05, 0.95, 0.3, 0.9, 0.4, 0.15, 0.18, 0.75, 0.01, 0.0, 0.7, 0.4],
//     [0.9, 0.4, 0.15, 0.18, 0.75, 0.01, 0.0, 0.7, 0.4, 0.05, 0.95, 0.3],
//     [0.18, 0.75, 0.01, 0.0, 0.7, 0.4, 0.05, 0.95, 0.3, 0.9, 0.4, 0.15],
//   ];
//
//   @override
//   void initState() {
//     _controller = AnimationController(vsync: this, duration: widget.duration)
//       ..repeat();
//
//     _animation = TweenSequence([
//       ...List.generate(11, (index) {
//         return TweenSequenceItem(
//             tween: Tween(begin: values[0][index], end: values[0][index + 1]),
//             weight: 100.0 / values.length);
//       }).toList()
//     ]).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
//
//     _animation1 = TweenSequence([
//       ...List.generate(11, (index) {
//         return TweenSequenceItem(
//           tween: Tween(begin: values[1][index], end: values[1][index + 1]),
//           weight: 100.0 / values.length,
//         );
//       }).toList()
//     ]).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
//
//     _animation2 = TweenSequence([
//       ...List.generate(11, (index) {
//         return TweenSequenceItem(
//             tween: Tween(begin: values[2][index], end: values[2][index + 1]),
//             weight: 100.0 / values.length);
//       }).toList()
//     ]).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
//
//     _animation3 = TweenSequence([
//       ...List.generate(11, (index) {
//         return TweenSequenceItem(
//             tween: Tween(begin: values[3][index], end: values[3][index + 1]),
//             weight: 100.0 / values.length);
//       }).toList()
//     ]).animate(CurvedAnimation(parent: _controller, curve: widget.curve));
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return AnimatedBuilder(
//       animation: _controller,
//       builder: (context, child) {
//         return Row(
//           crossAxisAlignment: CrossAxisAlignment.center,
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation.value * widget.height,
//             ),
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation1.value * widget.height,
//             ),
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation2.value * widget.height,
//             ),
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation3.value * widget.height,
//             ),
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation3.value * widget.height,
//             ),
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation3.value * widget.height,
//             ),
//             Bar(
//               color: widget.color,
//               width: widget.width,
//               borderRadius: widget.borderRadius,
//               height: _animation3.value * widget.height,
//             ),
//           ],
//         );
//       },);
//   }
// }
