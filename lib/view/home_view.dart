import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy_connection/widgets/custom_button_widget.dart';
import 'package:liquid_galaxy_connection/widgets/custom_header_widget.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const CustomHeaderWidget(),
          const SizedBox(height: 120.0),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButtonWidget(
                    text: 'RELAUNCH LG',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Get.toNamed('/relaunch_lg');
                    },
                  ),
                  const SizedBox(width: 20.0),
                  CustomButtonWidget(
                    text: 'SHUTDOWN LG',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Get.toNamed('/shutdown_lg');
                    },
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButtonWidget(
                    text: 'REBOOT LG',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Get.toNamed('/reboot_lg');
                    },
                  ),
                  const SizedBox(width: 20.0),
                  CustomButtonWidget(
                    text: 'SEARCH',
                    onPressed: () {
                      Get.toNamed('/search');
                    },
                    backgroundColor: Colors.blue,
                  ),
                ],
              ),
              const SizedBox(height: 50.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButtonWidget(
                    text: 'CLEAN KML',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Get.toNamed('/clean_kml');
                    },
                  ),
                  const SizedBox(width: 20.0),
                  CustomButtonWidget(
                    text: 'SEND KML',
                    backgroundColor: Colors.blue,
                    onPressed: () {
                      Get.toNamed('/send_kml');
                    
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
