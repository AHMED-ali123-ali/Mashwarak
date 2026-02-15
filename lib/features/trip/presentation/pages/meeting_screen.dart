import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/utils/firestore_service.dart';
import 'sure_screen.dart';

class MeetingScreen extends StatefulWidget {
  final String tripId;
  final LatLng start;
  final LatLng end;
  final String startPlaceName;
  final String endPlaceName;

  const MeetingScreen({
    super.key,
    required this.tripId,
    required this.start,
    required this.end,
    required this.startPlaceName,
    required this.endPlaceName,
  });

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  LatLng? selectedMeetingPoint;
  bool showMap = false;
  bool _isUpdating = false;
  final FirestoreService _firestoreService = FirestoreService();

  final TextEditingController _meetingController = TextEditingController();

  final double maxDistanceMeters = 2000;
  final Distance distanceCalculator = const Distance();

  final List<String> images = [
    'images/tuk1.webp',
    'images/tuk2.webp',
    'images/tuk3.webp',
    'images/tuk4.webp',
    'images/tuk5.webp',
  ];

  double calculateDistance(LatLng a, LatLng b) {
    return distanceCalculator.as(LengthUnit.Meter, a, b);
  }

  bool isValidMeetingPoint(LatLng point) {
    double distanceToStart = calculateDistance(point, widget.start);
    double distanceToEnd = calculateDistance(point, widget.end);
    return distanceToStart <= maxDistanceMeters &&
        distanceToEnd <= maxDistanceMeters;
  }

  Future<String> getPlaceName(double lat, double lon) async {
    try {
      final url =
          "https://nominatim.openstreetmap.org/reverse?format=json&lat=$lat&lon=$lon&accept-language=ar";

      final res = await http.get(
        Uri.parse(url),
        headers: {"User-Agent": "TokGo/1.0"},
      );

      if (res.statusCode == 200) {
        final data = json.decode(res.body);
        return data["display_name"] ?? "المكان المحدد";
      }
    } catch (e) {
      debugPrint(e.toString());
    }
    return "المكان المحدد";
  }

  @override
  Widget build(BuildContext context) {
    LatLng mapCenter = LatLng(
      (widget.start.latitude + widget.end.latitude) / 2,
      (widget.start.longitude + widget.end.longitude) / 2,
    );

    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
              color: Colors.black, shape: BoxShape.circle),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.orange),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "نقطة الالتقاء",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 25),
          CarouselSlider(
            options: CarouselOptions(
              height: 200,
              autoPlay: true,
              enlargeCenterPage: true,
            ),
            items: images.map((path) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4))
                  ],
                  image: DecorationImage(
                      image: AssetImage(path), fit: BoxFit.cover),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: InkWell(
              onTap: () => setState(() => showMap = true),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 6))
                  ],
                ),
                child: Row(
                  children: [
                    const Icon(Icons.map, color: Colors.black, size: 40),
                    const SizedBox(width: 15),
                    Expanded(
                      child: Center(
                        child: Text(
                          _meetingController.text.isEmpty
                              ? "اضغط لتحديد مكان الالتقاء"
                              : _meetingController.text,
                          style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.black),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: showMap
                ? FlutterMap(
                    options: MapOptions(
                      initialCenter: mapCenter,
                      initialZoom: 14,
                      onTap: (tap, point) async {
                        if (isValidMeetingPoint(point)) {
                          String name = await getPlaceName(
                              point.latitude, point.longitude);
                          setState(() {
                            selectedMeetingPoint = point;
                            _meetingController.text = name;
                          });
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                backgroundColor: Colors.red,
                                content: Center(
                                    child: Text(
                                  "المكان بعيد",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 40),
                                ))),
                          );
                        }
                      },
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=poneGPfuCb0jl0NnLfwb",
                        userAgentPackageName: "com.example.tokgo",
                      ),
                      CircleLayer(
                        circles: [
                          CircleMarker(
                            point: widget.start,
                            color: Colors.blue.withOpacity(0.1),
                            borderColor: Colors.blue,
                            borderStrokeWidth: 2,
                            useRadiusInMeter: true,
                            radius: maxDistanceMeters,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: widget.start,
                            child: const Icon(Icons.location_on,
                                color: Colors.red, size: 40),
                          ),
                          Marker(
                            point: widget.end,
                            child: const Icon(Icons.location_on,
                                color: Colors.green, size: 40),
                          ),
                          if (selectedMeetingPoint != null)
                            Marker(
                              point: selectedMeetingPoint!,
                              child: const Icon(Icons.person_pin_circle,
                                  color: Colors.blue, size: 45),
                            ),
                        ],
                      ),
                    ],
                  )
                : const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.touch_app, size: 80, color: Colors.green),
                        SizedBox(height: 10),
                        Text(
                          "افتح الخريطة لتحديد مكان اللقاء",
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 27,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: (selectedMeetingPoint != null && !_isUpdating)
                    ? () async {
                        setState(() => _isUpdating = true);
                        try {
                          // تحديث مكان الالتقاء في Firestore
                          await _firestoreService.updateMeetingPoint(
                            tripId: widget.tripId,
                            meetingPlace: _meetingController.text,
                            meetingLat: selectedMeetingPoint!.latitude,
                            meetingLng: selectedMeetingPoint!.longitude,
                          );

                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SureScreen(
                                  tripId: widget.tripId,
                                  startPlace: widget.startPlaceName,
                                  endPlace: widget.endPlaceName,
                                  meetingPlace: _meetingController.text,
                                  startLatLng: widget.start,
                                  endLatLng: widget.end,
                                  meetingLatLng: selectedMeetingPoint!,
                                ),
                              ),
                            );
                          }
                        } catch (e) {
                          debugPrint("Error updating meeting point: $e");
                        } finally {
                          if (mounted) setState(() => _isUpdating = false);
                        }
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                ),
                child: _isUpdating
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "تأكيد",
                        style: TextStyle(
                            fontSize: 27,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
