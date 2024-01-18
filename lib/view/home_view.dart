import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy_connection/viewmodel/setting_view_model.dart';
import 'package:liquid_galaxy_connection/widgets/custom_planet_widget.dart';
import 'package:liquid_galaxy_connection/widgets/custom_star_widget.dart';
import 'package:liquid_galaxy_connection/widgets/custom_button_widget.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  final SettingViewModel _viewModel = Get.put(SettingViewModel());
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 80),
    )..repeat();

    _animation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildBackground(),
          Padding(
            padding: const EdgeInsets.all(80.0),
            child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                customBorder: const CircleBorder(),
                splashColor: Colors.grey,
                onTap: () {
                  Get.toNamed('/settings');
                },
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(255, 219, 23, 111),
                        Color.fromARGB(255, 223, 102, 21),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.settings,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 120.0),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomButtonWidget(
                        text: 'RELAUNCH LG',
                        onPressed: () async {
                          await _viewModel.reLaunchLG();
                        },
                      ),
                      const SizedBox(width: 50.0),
                      CustomButtonWidget(
                        text: 'SHUTDOWN LG',
                        onPressed: () async {
                          await _viewModel.shutdownLG();
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      CustomButtonWidget(
                        text: 'REBOOT LG',
                        onPressed: () async {
                          await _viewModel.rebootLG();
                        },
                      ),
                      const SizedBox(width: 50.0),
                      CustomButtonWidget(
                        text: 'SEARCH',
                        onPressed: () async {
                          await _viewModel.query("India");
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 50.0),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CustomButtonWidget(
                        text: 'CLEAN KML',
                        onPressed: () async {},
                      ),
                      const SizedBox(width: 50.0),
                      CustomButtonWidget(
                        text: 'SEND KML',
                        onPressed: () async {},
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color.fromRGBO(27, 38, 44, 1),
                Color.fromRGBO(72, 87, 104, 1),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.3, 0.7],
            ),
          ),
        ),
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return ParallaxContainer(
                xParallax: _animation.value,
                yParallax: 0.0,
                child: CustomPaint(
                  painter: CustomPlanetWidget(_animation.value),
                ),
              );
            },
          ),
        ),
        Stack(
          children: List.generate(
            180,
            (index) => Positioned(
              left: getRandomPosition(),
              top: getRandomPosition(),
              child: CustomStarWidget(
                size: Random().nextInt(30).toDouble() + 10,
                color: getRandomColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double getRandomPosition() {
    return Random().nextDouble() * Get.width;
  }

  Color getRandomColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextDouble(),
    );
  }
}
