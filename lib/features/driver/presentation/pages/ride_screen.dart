import 'package:flutter/material.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

class RideScreen extends StatefulWidget {
  final LatLng startPlaceLatLng;
  final LatLng endPlaceLatLng;
  final LatLng meetingLatLng;
  final String startPlace;
  final String endPlace;
  final String meetingPlace;

  final String driverName;
  final String driverPhone;
  final String driverImage;
  final String driverPrice;

  const RideScreen({
    super.key,
    required this.startPlaceLatLng,
    required this.endPlaceLatLng,
    required this.meetingLatLng,
    required this.startPlace,
    required this.endPlace,
    required this.meetingPlace,
    required this.driverName,
    required this.driverPhone,
    required this.driverImage,
    required this.driverPrice,
  });

  @override
  State<RideScreen> createState() => _RideScreenState();
}

class _RideScreenState extends State<RideScreen> {
  LatLng? tukTukPosition;
  bool arrived = false;
  Timer? _timer;
  final MapController _mapController = MapController();
  late List<LatLng> routePoints;

  @override
  void initState() {
    super.initState();
    routePoints = [
      widget.startPlaceLatLng,
      widget.meetingLatLng,
      widget.endPlaceLatLng,
    ];
    tukTukPosition = routePoints.first;
    _moveTukTuk();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _moveTukTuk() {
    int currentIndex = 0;

    _timer = Timer.periodic(const Duration(milliseconds: 60), (timer) {
      if (currentIndex >= routePoints.length - 1) {
        timer.cancel();
        if (mounted) setState(() => arrived = true);
        return;
      }
      LatLng start = routePoints[currentIndex];
      LatLng end = routePoints[currentIndex + 1];

      double latStep = (end.latitude - start.latitude) / 80;
      double lngStep = (end.longitude - start.longitude) / 80;

      tukTukPosition = LatLng(
        tukTukPosition!.latitude + latStep,
        tukTukPosition!.longitude + lngStep,
      );

      if ((tukTukPosition!.latitude - end.latitude).abs() < 0.0001 &&
          (tukTukPosition!.longitude - end.longitude).abs() < 0.0001) {
        tukTukPosition = end;
        currentIndex++;
      }

      if (mounted) {
        setState(() {
          _mapController.move(tukTukPosition!, 16);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.startPlaceLatLng,
              initialZoom: 15,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=poneGPfuCb0jl0NnLfwb",
                userAgentPackageName: "com.tokgo.app",
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 6,
                    color: Colors.black,
                  ),
                ],
              ),
              MarkerLayer(
                markers: [
                  if (tukTukPosition != null)
                    Marker(
                      point: tukTukPosition!,
                      width: 60,
                      height: 60,
                      child: const Icon(Icons.electric_rickshaw,
                          color: Colors.orangeAccent, size: 50),
                    ),
                  Marker(
                    point: widget.startPlaceLatLng,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on,
                        color: Colors.green, size: 50),
                  ),
                  Marker(
                    point: widget.meetingLatLng,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.person, color: Colors.blue, size: 50),
                  ),
                  Marker(
                    point: widget.endPlaceLatLng,
                    width: 50,
                    height: 50,
                    child: const Icon(Icons.location_on,
                        color: Colors.red, size: 50),
                  ),
                ],
              ),
            ],
          ),
          if (!arrived)
            Positioned(
              bottom: 30,
              left: 15,
              right: 15,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(color: Colors.black, blurRadius: 15),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: AssetImage(widget.driverImage),
                    ),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(widget.driverName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 25)),
                          ),
                          const SizedBox(height: 13),
                          Center(
                              child: Text(
                            widget.driverPhone,
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          )),
                          const SizedBox(height: 13),
                          Center(
                            child: Text("السعر: ${widget.driverPrice} ج",
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.red)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.phone, color: Colors.green, size: 40),
                  ],
                ),
              ),
            ),
          if (arrived)
            Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 25,
                        offset: Offset(0, 5)),
                  ],
                ),
                child: Stack(
                  children: [
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Center(
                            child: Icon(Icons.check_circle,
                                color: Colors.green, size: 60)),
                        const SizedBox(height: 15),
                        const Text(
                          "تم الوصول بنجاح",
                          style: TextStyle(
                              fontSize: 29,
                              fontWeight: FontWeight.bold,
                              color: Colors.green),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "السعر المطلوب: ${widget.driverPrice} ج",
                          style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.close,
                            color: Colors.black, size: 34),
                        onPressed: () {
                          setState(() => arrived = false);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
