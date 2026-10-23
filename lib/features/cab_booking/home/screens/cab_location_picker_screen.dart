import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:sixam_mart/features/cab_booking/home/controllers/cab_controller.dart';
import 'package:sixam_mart/features/location/screens/pick_map_screen.dart';
import 'package:sixam_mart/util/dimensions.dart';
import 'package:sixam_mart/util/styles.dart';
import 'package:sixam_mart/util/images.dart';
import 'package:sixam_mart/helper/responsive_helper.dart';
import 'package:sixam_mart/features/location/controllers/location_controller.dart';
import 'package:sixam_mart/features/address/domain/models/address_model.dart';

class CabLocationPickerScreen extends StatefulWidget {
  final bool isPickup;
  const CabLocationPickerScreen({super.key, required this.isPickup});

  @override
  State<CabLocationPickerScreen> createState() => _CabLocationPickerScreenState();
}

class _CabLocationPickerScreenState extends State<CabLocationPickerScreen> {
  final TextEditingController _searchController = TextEditingController();
  late bool _isPickup;

  @override
  void initState() {
    super.initState();
    _isPickup = widget.isPickup;
    _searchController.text = _isPickup 
        ? (Get.find<CabController>().sourceAddress ?? '') 
        : (Get.find<CabController>().destinationAddress ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(_isPickup ? 'Pickup' : 'Drop', style: robotoBold.copyWith(color: Colors.black, fontSize: 18)),
        actions: const [SizedBox()],
      ),
      body: GetBuilder<CabController>(builder: (cabController) {
        return Column(children: [
          
          /// Address Input Card
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(children: [
              /// Pickup Row
              InkWell(
                onTap: () {
                  setState(() {
                    _isPickup = true;
                    _searchController.text = cabController.sourceAddress ?? '';
                    Get.find<LocationController>().predictionList.clear();
                  });
                },
                child: Row(children: [
                  const Icon(Icons.circle, color: Colors.green, size: 12),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _isPickup 
                      ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Pickup location',
                            hintStyle: robotoRegular.copyWith(color: Colors.grey, fontSize: 16),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                Get.find<LocationController>().predictionList.clear();
                                setState(() {});
                              },
                            ) : null,
                          ),
                          onChanged: (val) {
                            if (val.length > 2) {
                              Get.find<LocationController>().searchLocation(context, val);
                            } else if (val.isEmpty) {
                              Get.find<LocationController>().predictionList.clear();
                            }
                            setState(() {});
                          },
                        )
                      : Text(
                          cabController.sourceAddress ?? 'Pickup location',
                          style: robotoRegular.copyWith(fontSize: 16, color: cabController.sourceAddress == null ? Colors.grey : Colors.black),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ]),
              ),
              
              Padding(
                padding: const EdgeInsets.only(left: 5),
                child: Container(height: 10, width: 1, color: Colors.grey[300]),
              ),
              
              /// Drop Row
              InkWell(
                onTap: () {
                  setState(() {
                    _isPickup = false;
                    _searchController.text = cabController.destinationAddress ?? '';
                    Get.find<LocationController>().predictionList.clear();
                  });
                },
                child: Row(children: [
                  const Icon(Icons.circle, color: Colors.orange, size: 12),
                  const SizedBox(width: 15),
                  Expanded(
                    child: !_isPickup 
                      ? TextField(
                          controller: _searchController,
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Drop location',
                            hintStyle: robotoRegular.copyWith(color: Colors.grey, fontSize: 16),
                            border: InputBorder.none,
                            suffixIcon: _searchController.text.isNotEmpty ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () {
                                _searchController.clear();
                                Get.find<LocationController>().predictionList.clear();
                                setState(() {});
                              },
                            ) : null,
                          ),
                          onChanged: (val) {
                            if (val.length > 2) {
                              Get.find<LocationController>().searchLocation(context, val);
                            } else if (val.isEmpty) {
                              Get.find<LocationController>().predictionList.clear();
                            }
                            setState(() {});
                          },
                        )
                      : Text(
                          cabController.destinationAddress ?? 'Drop location',
                          style: robotoRegular.copyWith(fontSize: 16, color: cabController.destinationAddress == null ? Colors.grey : Colors.black),
                          maxLines: 1, overflow: TextOverflow.ellipsis,
                        ),
                  ),
                ]),
              ),
            ]),
          ),

          /// Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Expanded(child: InkWell(
                onTap: () => Get.to(() => PickMapScreen(
                  fromSignUp: false, fromAddAddress: false, canRoute: false, route: '',
                  onPicked: (address) {
                    LatLng latLng = LatLng(double.parse(address.latitude!), double.parse(address.longitude!));
                    if(_isPickup) {
                      cabController.setSource(latLng, address.address!, null);
                    } else {
                      cabController.setDestination(latLng, address.address!, null);
                    }
                    Get.back(); // Back to this screen
                    // If both are now set, we could go back home, or stay to allow editing the other
                    if(cabController.sourceAddress != null && cabController.destinationAddress != null) {
                       Get.back();
                    }
                  },
                )),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.location_on_outlined, size: 20),
                    const SizedBox(width: 8),
                    Text('Select on map', style: robotoMedium.copyWith(fontSize: 14)),
                  ]),
                ),
              )),
              const SizedBox(width: 15),
            ]),
          ),

          const SizedBox(height: 20),
          const Divider(thickness: 1, color: Color(0xFFF1F1F1)),

          /// Suggestions or History
          Expanded(
            child: GetBuilder<LocationController>(builder: (locationController) {
              return (locationController.predictionList.isNotEmpty && _searchController.text.isNotEmpty) ? ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: locationController.predictionList.length,
                itemBuilder: (context, index) {
                  final prediction = locationController.predictionList[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.location_on, color: Colors.grey),
                    title: Text(prediction.description!, style: robotoRegular.copyWith(fontSize: 14), maxLines: 2, overflow: TextOverflow.ellipsis),
                    onTap: () async {
                      AddressModel address = await locationController.setLocation(prediction.placeId, prediction.description, null);
                      LatLng latLng = LatLng(double.parse(address.latitude!), double.parse(address.longitude!));
                      if(_isPickup) {
                        cabController.setSource(latLng, address.address!, null);
                      } else {
                        cabController.setDestination(latLng, address.address!, null);
                      }
                      
                      if(cabController.sourceAddress != null && cabController.destinationAddress != null) {
                        Get.back();
                      } else {
                        setState(() {
                          _isPickup = !_isPickup;
                          _searchController.text = _isPickup 
                              ? (cabController.sourceAddress ?? '') 
                              : (cabController.destinationAddress ?? '');
                          Get.find<LocationController>().predictionList.clear();
                        });
                      }
                    },
                  );
                },
              ) : (cabController.rideList == null ? const Center(child: CircularProgressIndicator()) : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                itemCount: cabController.rideList!.length,
                separatorBuilder: (c, i) => const Divider(height: 30, color: Colors.grey, thickness: 0.1, indent: 40),
                itemBuilder: (context, index) {
                  final ride = cabController.rideList![index];
                  String locationName = ride.dropLocation ?? 'Recent Location';
                  return InkWell(
                    onTap: () {
                      LatLng latLng = LatLng(ride.dropLat!, ride.dropLng!);
                      if(_isPickup) {
                        cabController.setSource(latLng, locationName, null);
                      } else {
                        cabController.setDestination(latLng, locationName, null);
                      }
                      
                      if(cabController.sourceAddress != null && cabController.destinationAddress != null) {
                        Get.back();
                      } else {
                        setState(() {
                          _isPickup = !_isPickup;
                          _searchController.text = _isPickup 
                              ? (cabController.sourceAddress ?? '') 
                              : (cabController.destinationAddress ?? '');
                          Get.find<LocationController>().predictionList.clear();
                        });
                      }
                    },
                    child: Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: Colors.grey[50], shape: BoxShape.circle),
                        child: const Icon(Icons.history, color: Colors.grey, size: 20),
                      ),
                      const SizedBox(width: 15),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(locationName.split(',').first.toUpperCase(), style: robotoBold.copyWith(fontSize: 16)),
                        Text(locationName, style: robotoRegular.copyWith(fontSize: 12, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ])),
                    ]),
                  );
                },
              ));
            }),
          ),
        ]);
      }),
    );
  }
}
