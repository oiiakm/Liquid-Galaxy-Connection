import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingViewModel extends GetxController {
  late RxString ipAddress = ''.obs;
  late RxString sshPort = ''.obs;
  late RxString userName = ''.obs;
  late RxString password = ''.obs;
  late RxString numberOfRigs = ''.obs;
  RxBool isConnected = false.obs;

  SSHClient? client;

  @override
  void onInit() {
    super.onInit();
    connectToLG();
    fetchData();
  }

  Future<Map<String, dynamic>> fetchData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      ipAddress.value = prefs.getString('ipAddress') ?? '';
      sshPort.value = prefs.getString('sshPort') ?? '';
      userName.value = prefs.getString('userName') ?? '';
      password.value = prefs.getString('password') ?? '';
      numberOfRigs.value = prefs.getString('numberOfRigs') ?? '';

      final connectionData = {
        'ipAddress': ipAddress.value,
        'sshPort': sshPort.value,
        'userName': userName.value,
        'password': password.value,
        'numberOfRigs': numberOfRigs.value,
      };

      return connectionData;
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateData() async {
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('ipAddress', ipAddress.value);
      await prefs.setString('sshPort', sshPort.value);
      await prefs.setString('userName', userName.value);
      await prefs.setString('password', password.value);
      isConnected.value = true;
    } catch (error) {
      print('Error updating data: $error');

      isConnected.value = false;
    }
  }

  void updateConnectionStatus(bool status) {
    isConnected.value = status;
  }

  // Connect LG
  Future<bool?> connectToLG() async {
    await fetchData();
    try {
      client = SSHClient(
        await SSHSocket.connect(ipAddress.value, int.parse(sshPort.value)),
        username: userName.value,
        onPasswordRequest: () => password.value,
      );
      isConnected.value = true;
      return true;
    } on SocketException catch (e) {
      print(e);

      isConnected.value = false;
      return false;
    }
  }

//shutdown LG
  Future<SSHSession?> shutdownLG() async {
    try {
      if (ipAddress.value.isEmpty) {
        return null;
      }
      for (int i = int.parse(numberOfRigs.value); i > 0; i--) {
        await client!.execute(
            'sshpass -p $password ssh -t lg$i "echo $password | sudo -S poweroff"');
      }

      return null;
    } catch (e) {
      return null;
    }
  }

//relaunch LG
  Future<SSHSession?> reLaunchLG() async {
    try {
      if (ipAddress.value.isEmpty) {
        return null;
      }

      final result = await client!.execute("""RELAUNCH_CMD="\\
         if [ -f /etc/init/lxdm.conf ]; then
         export SERVICE=lxdm
         elif [ -f /etc/init/lightdm.conf ]; then
         export SERVICE=lightdm
          else
         exit 1
         fi
         if  [[ \\\$(service \\\$SERVICE status) =~ 'stop' ]]; then
         echo $password | sudo -S service \\\${SERVICE} start
         else
            echo $password | sudo -S service \\\${SERVICE} restart
        fi
        " && sshpass -p $password ssh -x -t lg@lg1 "\$RELAUNCH_CMD\"""");

      return result;
    } catch (e) {
      return null;
    }
  }

//reboot LG
  Future<SSHSession?> rebootLG() async {
    try {
      if (ipAddress.value.isEmpty) {
        return null;
      }
      for (int i = int.parse(numberOfRigs.value); i > 0; i--) {
        await client!.execute(
            'sshpass -p $password ssh -t lg$i "echo $password | sudo -S reboot"');
      }
      return null;
    } catch (e) {
      return null;
    }
  }

//search on LG
  Future<SSHSession?> query(String search) async {
    try {
      if (ipAddress.value.isEmpty) {
        return null;
      }
      SSHSession result =
          await client!.execute('echo "search=$search" > /tmp/query.txt');

      return result;
    } catch (e) {
      return null;
    }
  }
}
