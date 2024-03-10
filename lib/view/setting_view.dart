import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:liquid_galaxy_connection/controller/ssh_controller.dart';
import 'package:liquid_galaxy_connection/widgets/custome_text_field_widget.dart';

class SettingView extends StatelessWidget {
  final SSHController _viewModel = Get.put(SSHController());

  SettingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _viewModel.fetchData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.purple, Colors.indigo, Colors.blue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(40.0),
                child: Align(
                  alignment: Alignment.topLeft,
                  child: Row(
                    children: [
                      Obx(
                        () => Icon(
                          _viewModel.isConnected.value
                              ? Icons.check_circle
                              : Icons.error,
                          color: _viewModel.isConnected.value
                              ? Colors.green
                              : Colors.red,
                          size: 30.0,
                        ),
                      ),
                      const SizedBox(width: 5.0),
                      Obx(
                        () => Text(
                          _viewModel.isConnected.value
                              ? 'Connected'
                              : 'Disconnected',
                          style: TextStyle(
                            color: _viewModel.isConnected.value
                                ? Colors.green
                                : Colors.red,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Stack(children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Text(
                            'LG Configuration',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        CustomTextFieldWidget(
                          labelText: 'IP Address',
                          hintText: '255.255.255.255',
                          initialValue: _viewModel.ipAddress.value,
                          onChanged: (value) =>
                              _viewModel.ipAddress.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Port',
                          hintText: '22',
                          initialValue: _viewModel.sshPort.value,
                          onChanged: (value) =>
                              _viewModel.sshPort.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Username',
                          initialValue: _viewModel.userName.value,
                          onChanged: (value) =>
                              _viewModel.userName.value = value,
                          hintText: '',
                        ),
                        const SizedBox(height: 16.0),
                        CustomTextFieldWidget(
                          labelText: 'Password',
                          hintText: 'lg',
                          obsecureText: true,
                          initialValue: _viewModel.password.value,
                          onChanged: (value) =>
                              _viewModel.password.value = value,
                        ),
                        const SizedBox(height: 10.0),
                        CustomTextFieldWidget(
                          labelText: 'Number Of Rigs',
                          hintText: '3',
                          initialValue: _viewModel.numberOfRigs.value,
                          onChanged: (value) =>
                              _viewModel.numberOfRigs.value = value,
                        ),
                        const SizedBox(height: 30.0),
                        Center(
                          child: ElevatedButton(
                            onPressed: () async {
                              _viewModel.updateConnectionStatus(false);
                              await _viewModel.updateData();
                              await _viewModel.connectToLG(maxRetries: 1);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 76, 63, 63)
                                      .withOpacity(0.9),
                              elevation: 5.0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              padding: const EdgeInsets.symmetric(
                                  vertical: 20.0, horizontal: 60.0),
                            ),
                            child: const Text(
                              'Save',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
