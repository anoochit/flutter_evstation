import 'dart:developer';

import 'package:evcstation/controller/app_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SearchBody extends StatelessWidget {
  const SearchBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AppController>(
      builder: (controller) {
        log('load marker =  ${controller.setMarkers.length}');
        return Stack(
          children: [
            // Map
            GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: LatLng(13.7563, 100.5018),
                zoom: 12,
              ),
              onMapCreated: (mapController) {
                // map controller
                controller.mapController = mapController;

                // set mapstyle
                mapController.setMapStyle(controller.mapStyle.value);

                // search nearby when map create
                controller.searchNearBy(
                  position: const LatLng(13.7563, 100.5018),
                );

                // update controller
                controller.update();
              },
              onCameraIdle: () {
                log("camera idle");
              },
              onCameraMove: (cameraPosition) {
                log('${cameraPosition.target.latitude}, ${cameraPosition.target.longitude}');
              },
              markers: controller.setMarkers,
              mapType: MapType.normal,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: false,
            ),

            // Search
            Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 64.0, left: 16, right: 16),
                child: Container(
                  height: 40,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(
                        32.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade300,
                          blurRadius: 3.0,
                        )
                      ]),
                  child: TextFormField(
                    onTap: () {
                      log("text field tap");
                      controller.hideSearchResult();
                    },
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      prefixIcon: Icon(Icons.search),
                      border: InputBorder.none,
                    ),
                    onFieldSubmitted: (value) {
                      // search by location
                      controller.searchByLocation(location: value.trim()).then((location) {
                        controller.searchNearBy(
                          position: LatLng(location.latitude, location.longitude),
                        );
                        controller.mapController.animateCamera(
                          CameraUpdate.newCameraPosition(
                            CameraPosition(
                              target: LatLng(location.latitude, location.longitude),
                              zoom: 12,
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),
            ),

            // Result
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 64,
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12.0),
                    topRight: Radius.circular(12.0),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    // show result in bottomsheet
                    if (controller.setMarkers.isNotEmpty) {
                      // set show bottom sheet status
                      controller.showResult.value = true;
                      // show bottom sheet
                      showBottomSheet(
                          backgroundColor: Colors.transparent,
                          context: context,
                          builder: (context) {
                            return Container(
                              clipBehavior: Clip.antiAliasWithSaveLayer,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topRight: Radius.circular(12.0),
                                  topLeft: Radius.circular(12.0),
                                ),
                              ),
                              height: (controller.evStations.length > 10)
                                  ? (64 * 10)
                                  : ((controller.evStations.length * (48 + 8)) + 32),
                              child: Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Container(
                                      width: MediaQuery.of(context).size.width * 0.5,
                                      height: 4.0,
                                      decoration: BoxDecoration(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: ListView(
                                      children: controller.evStations.map((station) {
                                        return ListTile(
                                          leading: const Icon(Icons.charging_station),
                                          title: Text(station.documentSnapshot.data()["name"]),
                                          trailing: Text('${station.kmDistance}'),
                                        );
                                      }).toList(),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          });
                    }
                  },
                  child: Text(
                    (controller.setMarkers.isNotEmpty)
                        ? 'Found ${controller.setMarkers.length} station'
                        : 'EV station not found',
                    style: const TextStyle(color: Colors.white, fontSize: 20.0),
                  ),
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
