import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy_connection/routes/route_config.dart';
import 'package:flutter/services.dart';
import 'routes/route_error.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    List<DeviceOrientation> preferredOrientations = screenSize.width > 600
        ? [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]
        : [DeviceOrientation.portraitUp];

    SystemChrome.setPreferredOrientations(preferredOrientations);

    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      unknownRoute:
          GetPage(name: '/route_error', page: () => const RouteErrorView()),
      getPages: AppRoutes.pages,
    );
  }
}