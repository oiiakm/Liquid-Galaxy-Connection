import 'dart:io';
import 'package:dartssh2/dartssh2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SSHController extends GetxController {
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
      await prefs.setString('numberOfRigs', numberOfRigs.value);
    } catch (error) {
      print('Error updating data: $error');

      isConnected.value = false;
    }
  }

  void updateConnectionStatus(bool status) {
    isConnected.value = status;
    update();
  }

  // Connect LG with retries
  Future<bool?> connectToLG({int maxRetries = 10}) async {
    int retryCount = 0;

    while (retryCount < maxRetries && !isConnected.value) {
      await fetchData();

      try {
        client = SSHClient(
          await SSHSocket.connect(ipAddress.value, int.parse(sshPort.value)),
          username: userName.value,
          onPasswordRequest: () => password.value,
          keepAliveInterval: const Duration(seconds: 30),
        );
        isConnected.value = true;

        Get.snackbar(
          'Successful',
          'Connected to LG Rigs',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );

        return true;
      } on SocketException catch (e) {
        print(e);
        isConnected.value = false;
        retryCount++;

        if (retryCount == 1) {
          Get.snackbar(
            'Failed',
            'Retrying connection (attempt $retryCount)...',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }

        await Future.delayed(const Duration(seconds: 1));

        continue;
      }
    }

    if (!isConnected.value) {
      Get.snackbar(
        'Connection Error',
        'Failed to connect after $maxRetries attempts.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      print('Failed to connect after $maxRetries attempts.');
      return false;
    }

    return true;
  }

//shutdown LG
  Future<SSHSession?> shutdownLG() async {
    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return null;
      }

      for (int i = int.parse(numberOfRigs.value); i > 0; i--) {
        await client!.execute(
            'sshpass -p $password ssh -t lg$i "echo $password | sudo -S poweroff"');
        await Future.delayed(const Duration(seconds: 1));
      }
      client!.close();
      isConnected.value = false;
      return null;
    } catch (e) {
      return null;
    }
  }

//relaunch LG
  Future<SSHSession?> reLaunchLG() async {
    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
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
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return null;
      }

      List<Future<SSHSession?>> commands = [];
      for (int i = int.parse(numberOfRigs.value); i > 0; i--) {
        commands.add(client!.execute(
            'sshpass -p $password ssh -t lg$i "echo $password | sudo -S reboot"'));
        await Future.delayed(const Duration(seconds: 1));
      }

      List<SSHSession?> results = await Future.wait(commands);
      client!.close();
      isConnected.value = false;
      await Future.delayed(const Duration(seconds: 6));

      await connectToLG(maxRetries: 20);

      return results.isNotEmpty ? results.last : null;
    } catch (e) {
      isConnected.value = false;
      return null;
    }
  }

//search on LG
  Future<SSHSession?> query(String search) async {
    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return null;
      }
      final result =
          await client!.execute('echo "search=$search" > /tmp/query.txt');

      return result;
    } catch (e) {
      return null;
    }
  }

  int get leftSlave {
    if (int.parse(numberOfRigs.value) == 1) {
      return 1;
    }

    return (int.parse(numberOfRigs.value) / 2).floor() + 2;
  }

  int get rightSlave {
    if (int.parse(numberOfRigs.value) == 1) {
      return 1;
    }

    return (int.parse(numberOfRigs.value) / 2).floor() + 1;
  }

//clean
  Future<void> cleanKML() async {
    String kmlName = '''
<?xml version="1.0" encoding="UTF-8"?>
<kml xmlns="http://www.opengis.net/kml/2.2"
xmlns:gx="http://www.google.com/kml/ext/2.2"
xmlns:kml="http://www.opengis.net/kml/2.2"
xmlns:atom="http://www.w3.org/2005/Atom">
  <Document id="3">
  </Document>
</kml>
''';

    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return;
      }
      await client!
          .execute("echo '$kmlName' > /var/www/html/kml/slave_$rightSlave.kml");
      await Future.delayed(const Duration(seconds: 1));
      await client!
          .execute("echo '$kmlName' > /var/www/html/kml/slave_$leftSlave.kml");
    } catch (e) {
      return;
    }
  }

//send kml
  Future<SSHSession?> sendKMLToLG() async {
    String kmlName = '''
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:atom="http://www.w3.org/2005/Atom"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
    <Document>
        <Folder>
            <name>Logos</name>
            <ScreenOverlay>
                <name>Logo</name>
                <Icon>
                    <href>https://raw.githubusercontent.com/oiiakm/Laser-Slides/main/screenshots/app_logo.png</href>
                </Icon>
                <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                <screenXY x="0.02" y="1" xunits="fraction" yunits="fraction"/>
                <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                <size x="500" y="500" xunits="pixels" yunits="pixels"/>
            </ScreenOverlay>
        </Folder>
    </Document>
</kml>
''';
    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return null;
      }

      SSHSession result = await client!
          .execute("echo '$kmlName' > /var/www/html/kml/slave_$leftSlave.kml");

      return result;
    } catch (e) {
      return null;
    }
  }

//setup slave to refresh every 2 seconds
  Future<void> setRefresh() async {
    await connectToLG();
    const search = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';
    const replace =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    final command =
        'echo $password | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    final clear =
        'echo $password | sudo -S sed -i "s/$replace/$search/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= int.parse(numberOfRigs.value); i++) {
      final clearCmd = clear.replaceAll('{{slave}}', i.toString());
      final cmd = command.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $password ssh -t lg$i \'{{cmd}}\'';

      try {
        await client!.execute(query.replaceAll('{{cmd}}', clearCmd));
        await client!.execute(query.replaceAll('{{cmd}}', cmd));
      } catch (e) {
        print(e);
      }
    }
    Future.delayed(const Duration(seconds: 1));
    await rebootLG();
  }

  ///slave screens to stop refreshing.
  Future<void> stopRefresh() async {
    await connectToLG();
    const search =
        '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href><refreshMode>onInterval<\\/refreshMode><refreshInterval>2<\\/refreshInterval>';
    const replace = '<href>##LG_PHPIFACE##kml\\/slave_{{slave}}.kml<\\/href>';

    final clear =
        'echo $password | sudo -S sed -i "s/$search/$replace/" ~/earth/kml/slave/myplaces.kml';

    for (var i = 2; i <= int.parse(numberOfRigs.value); i++) {
      final cmd = clear.replaceAll('{{slave}}', i.toString());
      String query = 'sshpass -p $password ssh -t lg$i \'$cmd\'';

      try {
        await client!.execute(query);
      } catch (e) {
        print(e);
      }
    }
    Future.delayed(const Duration(seconds: 1));
    await rebootLG();
  }

//visit my city
  Future<void> visitMyCity() async {
    double latitude = 24.2129;
    double longitude = 83.2403;
    if (isConnected.value) {
      String orbitLookAtLinear =
          '<gx:duration>3</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>900</range><tilt>60</tilt><heading>10.0</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

      await client!
          .execute('echo "flytoview=$orbitLookAtLinear" > /tmp/query.txt');
    }
  }

  // start orbit
  Future<void> startOrbit() async {
    double latitude = 24.2129;
    double longitude = 83.2403;
    if (isConnected.value) {
      try {
        int i = 0;
        while (true) {
          double angle = i.toDouble() % 360;
          String orbitLookAtLinear =
              '<gx:duration>3</gx:duration><gx:flyToMode>smooth</gx:flyToMode><LookAt><longitude>$longitude</longitude><latitude>$latitude</latitude><range>900</range><tilt>60</tilt><heading>$angle</heading><gx:altitudeMode>relativeToGround</gx:altitudeMode></LookAt>';

          await client!
              .execute('echo "flytoview=$orbitLookAtLinear" > /tmp/query.txt');
          await Future.delayed(const Duration(seconds: 3));

          i += 10;
        }
      } catch (error) {
        print(error);
      }
    }
  }

  //send HTML bubble
  Future<SSHSession?> sendHTMLBubble() async {
    String kmlName = '''
<kml xmlns="http://www.opengis.net/kml/2.2"
     xmlns:atom="http://www.w3.org/2005/Atom"
     xmlns:gx="http://www.google.com/kml/ext/2.2">
    <Document>
        <Folder>
            <name>Logos</name>
            <ScreenOverlay>
                <name>Logo</name>
                <Icon>
                    <href>https://raw.githubusercontent.com/oiiakm/Liquid-Galaxy-Connection/main/assets/name_city.jpg</href>
                </Icon>
                <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
                <screenXY x="0.02" y="1" xunits="fraction" yunits="fraction"/>
                <rotationXY x="0" y="0" xunits="fraction" yunits="fraction"/>
                <!-- Set the size to 30x30 -->
                <size x="500" y="500" xunits="pixels" yunits="pixels"/>
            </ScreenOverlay>
        </Folder>
    </Document>
</kml>
''';
    try {
      if (ipAddress.value.isEmpty || isConnected.value == false) {
        return null;
      }

      SSHSession result = await client!
          .execute("echo '$kmlName' > /var/www/html/kml/slave_$rightSlave.kml");

      return result;
    } catch (e) {
      return null;
    }
  }
}
