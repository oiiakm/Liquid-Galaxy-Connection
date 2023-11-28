import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class CustomHeaderWidget extends StatelessWidget {
  const CustomHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = Get.width;
    double screenHeight = Get.height;

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color.fromARGB(255, 54, 212, 138),
      ),
    );

    return SizedBox(
      width: screenWidth,
      height: screenHeight / 7,
      child: Stack(
        children: [
          Container(
            width: screenWidth,
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 54, 212, 138),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(25),
                topRight: Radius.circular(25),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0x3F000000),
                  blurRadius: 20,
                  offset: Offset(0, 4),
                  spreadRadius: 4,
                ),
              ],
            ),
          ),
          const Positioned(
            left: 16,
            top: 55,
            child: Text(
              'Liquid Galaxy Connection',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
              ),
            ),
          ),
          Positioned(
            right: 30,
            top: 55,
            child: GestureDetector(
              onDoubleTap: () {
                Get.toNamed('/settings');
              },
              child: const Icon(
                Icons.settings,
                size: 35,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
