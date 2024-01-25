import 'package:get/get.dart';
import 'package:liquid_galaxy_connection/view/home_view.dart';
import 'package:liquid_galaxy_connection/routes/route_error.dart';
import 'package:liquid_galaxy_connection/view/setting_view.dart';

class AppRoutes {
  static final List<GetPage> pages = [
    GetPage(name: '/', page: () => const HomeView()),
    GetPage(name: '/route_error', page: () => const RouteErrorView()),
    GetPage(name: '/settings', page: () =>  SettingView()),
  ];
}
