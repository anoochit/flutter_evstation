import 'dart:developer';

import 'package:evcstation/controller/app_controller.dart';
import 'package:evcstation/pages/notifications/notifications_body.dart';
import 'package:evcstation/pages/profile/profile_body.dart';
import 'package:evcstation/pages/qrscan/qrscan_body.dart';
import 'package:evcstation/pages/search/search_body.dart';
import 'package:evcstation/pages/wallet/wallet_body.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  AppController controller = Get.find<AppController>();

  @override
  void initState() {
    super.initState();

    getCurrentPosition().then((position) {
      // get current position
      log('current position ${position.latitude}, ${position.longitude}');

      // get stream location
      controller.streamPosition = Geolocator.getPositionStream().listen((position) {
        log('stream position ${position.latitude}, ${position.longitude}');
      });
    });
  }

  // get current location
  Future<Position> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        return Scaffold(
          body: IndexedStack(
            index: controller.navIndex.value,
            children: const [
              // search
              SearchBody(),

              // wallet
              WalletBody(),

              // qrscan
              QRScanBody(),

              // notification
              NotificationBody(),

              // profile
              ProfileBody(),
            ],
          ),

          // bottom navigation
          bottomNavigationBar: BottomNavigationBar(
            selectedItemColor: Colors.blue,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            currentIndex: controller.navIndex.value,
            onTap: (value) {
              controller.hideSearchResult();
              controller.navIndex.value = value;
              controller.update();
            },
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
              BottomNavigationBarItem(icon: Icon(Icons.wallet), label: 'Wallet'),
              BottomNavigationBarItem(icon: Icon(Icons.qr_code), label: 'QR Scan'),
              BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Notifications'),
              BottomNavigationBarItem(icon: Icon(Icons.account_circle), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}
