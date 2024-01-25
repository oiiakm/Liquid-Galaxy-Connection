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
          SingleChildScrollView(
            child: Column(
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0, right: 50.0),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                            _showSearchDialog(context);
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
                      children: [
                        CustomButtonWidget(
                          text: 'CLEAN KML',
                          onPressed: () async {
                            await _viewModel.cleanKML();
                          },
                        ),
                        const SizedBox(width: 50.0),
                        CustomButtonWidget(
                          text: 'SEND KML',
                          onPressed: () async {
                            await _viewModel.sendKMLToLG("3");
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
                          text: 'START REFRESH',
                          onPressed: () async {
                            _showRefreshDialog(context,
                                "The slave will start refreshing every 2 seconds.");
                          },
                        ),
                        const SizedBox(width: 50.0),
                        CustomButtonWidget(
                          text: 'STOP REFRESH',
                          onPressed: () async {
                            _showRefreshDialog(
                                context, "The slave will stop refreshing");
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
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
              left: _getRandomPosition(),
              top: _getRandomPosition(),
              child: CustomStarWidget(
                size: Random().nextInt(30).toDouble() + 10,
                color: _getRandomColor(),
              ),
            ),
          ),
        ),
      ],
    );
  }

  double _getRandomPosition() {
    return Random().nextDouble() * Get.width;
  }

  Color _getRandomColor() {
    return Color.fromRGBO(
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextInt(256),
      Random().nextDouble(),
    );
  }

  void _showSearchDialog(context) {
    TextEditingController searchController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Container(
            alignment: Alignment.center,
            width: 350,
            height: 400,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 123, 104, 238),
                  Color.fromARGB(255, 216, 64, 171),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(10.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.7),
                    ),
                    padding: const EdgeInsets.all(12.0),
                    child: const Text(
                      'Search Place',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 60,
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: TextField(
                      controller: searchController,
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                      decoration: const InputDecoration(
                        labelText: 'Place Name',
                        labelStyle: TextStyle(color: Colors.white),
                        fillColor: Color(0xFF004E64),
                        filled: true,
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      elevation: 0,
                    ),
                    onPressed: () async {
                      String search = searchController.text;
                      await _viewModel.query(search);
                      Get.back();
                    },
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                        ),
                        borderRadius: BorderRadius.circular(16.0),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      child: const Center(
                        child: Text(
                          'Search',
                          style: TextStyle(color: Colors.white, fontSize: 20),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showRefreshDialog(context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          contentPadding: EdgeInsets.zero,
          elevation: 10,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          content: Container(
            alignment: Alignment.center,
            width: 350,
            height: 250,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 123, 104, 238),
                  Color.fromARGB(255, 216, 64, 171),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.0),
            ),
            padding: const EdgeInsets.all(10.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.7),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: const Text(
                    'Confirmation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      onPressed: () async {
                        if (message
                            .startsWith("The slave will start refreshing")) {
                          await _viewModel.setRefresh();
                          Get.back();
                        } else if (message
                            .startsWith("The slave will stop refreshing")) {
                          await _viewModel.stopRefresh();
                          Get.back();
                        }
                      },
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF00B4DB), Color(0xFF0083B0)],
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Proceed',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                      ),
                      onPressed: () {
                        Get.back();
                      },
                      child: Container(
                        width: 120,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFDC143C), Color(0xFF8B0000)],
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: Text(
                            'Cancel',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
