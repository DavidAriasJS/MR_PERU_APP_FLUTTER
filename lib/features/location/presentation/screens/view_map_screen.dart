
import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewMapScreen extends StatefulWidget {
  String coors;

  ViewMapScreen({super.key, required this.coors});

  @override
  State<ViewMapScreen> createState() => _ViewMapScreenState();
}

class _ViewMapScreenState extends State<ViewMapScreen> {
  late BitmapDescriptor markerIcon;
  
  @override
  void initState() {
    super.initState();
    _loadMarkerIcon();
  }

  Future<void> _loadMarkerIcon() async {
    markerIcon = await BitmapDescriptor.fromAssetImage(
      const ImageConfiguration(size: Size(16, 16)),
      'assets/images/marker_map.png',
    );
    setState(() {}); // Actualiza el estado después de cargar el icono
  }

  @override
  Widget build(BuildContext context) {
    List<String> coorsString = widget.coors.split(",");

    double lat = double.parse(coorsString[0].trim());
    double lng = double.parse(coorsString[1].trim());

    LatLng latLng = LatLng(lat, lng);

    CameraPosition initialCameraPosition =
        CameraPosition(target: latLng, zoom: 18);

    final size = MediaQuery.of(context).size;


    GoogleMapController? _mapController;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            SizedBox(
              width: size.width,
              height: size.height,
              child: GoogleMap(
                initialCameraPosition: initialCameraPosition,
                mapType: MapType.normal,
                markers: {
                  Marker(markerId: const MarkerId('Point center'), position: latLng, icon: markerIcon)
                },
                onMapCreated: (GoogleMapController controller) {
                  _mapController = controller;
                },
              ),
            ),

            FadeInLeft(
              duration: const Duration(milliseconds: 300),
              child: SafeArea(
                child: Container(
                  margin: const EdgeInsets.only(top: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  width: double.infinity,
                  
                  child: Row(
                    children: [
                      CircleAvatar(
                        maxRadius: 24,
                        backgroundColor: Colors.amberAccent,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back_ios_new,
                              color: Colors.black),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                      
                    ],
                  ),
                ),
              ),
            ),

            Positioned(
              right: 16.0,
              top: 36.0,
              child: FloatingActionButton(
                onPressed: () {
                  final cameraUpdate = CameraUpdate.newLatLng(latLng);
                  _mapController?.animateCamera(cameraUpdate);
                  
                },
                child: const Icon(Icons.location_on),
              ),
            )
          ],
        ),
      ),
    );
  }
}
