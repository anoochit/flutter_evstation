import 'dart:async';
import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geoflutterfire/geoflutterfire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class AppController extends GetxController {
  // nav index
  RxInt navIndex = 0.obs;

  Set<Marker> setMarkers = <Marker>{};

  late GoogleMapController mapController;

  late FirebaseFirestore firestore;

  RxString mapStyle = "".obs;

  RxList evStations = [].obs;

  late StreamSubscription<Position> streamPosition;

  RxBool showResult = false.obs;

  @override
  void onInit() {
    super.onInit();
    // firebase init
    firestore = FirebaseFirestore.instance;
    // load mapstyle
    loadMapStyle();
  }

  // search fencing
  searchNearBy({required LatLng position}) {
    // search in firestore
    Geoflutterfire geo = Geoflutterfire();
    GeoFirePoint center = GeoFirePoint(position.latitude, position.longitude);

    final result = geo
        .collection(collectionRef: firestore.collection('stations'))
        .withinWithDistance(center: center, radius: 5, field: 'location');

    result.listen((stations) {
      log('total = ${stations.length}');

      // set ev station list
      evStations.value = stations;

      // clear marker data
      setMarkers.clear();

      // make map marker
      stations.forEach((element) {
        log(element.documentSnapshot['name']);
        // make set makers
        GeoPoint geoPoint = element.documentSnapshot['location']['geopoint'];
        setMarkers.add(
          Marker(
            markerId: MarkerId(element.documentSnapshot.id),
            position: LatLng(geoPoint.latitude, geoPoint.longitude),
            infoWindow: InfoWindow(title: element.documentSnapshot['name']),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          ),
        );
      });
      update();
    });
  }

  // search by location
  Future<Location> searchByLocation({required String location}) async {
    List<Location> locations = await locationFromAddress(location);
    log('search at position = ${locations.first.latitude}, ${locations.first.longitude}');
    return locations.first;
  }

  loadMapStyle() async {
    String style = await rootBundle.loadString("assets/mapstyle.json");
    mapStyle.value = style;
  }

  hideSearchResult() {
    if (showResult.value == true) {
      showResult.value = false;
      Get.back();
    }
  }
}
