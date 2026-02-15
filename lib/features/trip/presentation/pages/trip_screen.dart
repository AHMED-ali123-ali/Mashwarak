import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/utils/firestore_service.dart';
import 'meeting_screen.dart';

class TripScreen extends StatefulWidget {
  final String tripId;
  const TripScreen({super.key, required this.tripId});
  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  final TextEditingController startController = TextEditingController();
  final TextEditingController endController = TextEditingController();
  final FirestoreService _firestoreService = FirestoreService();
  LatLng? startLatLng;
  LatLng? endLatLng;
  bool _isUpdating = false;

  final List<String> images = [
    'images/tuk1.webp',
    'images/tuk2.webp',
    'images/tuk3.webp',
    'images/tuk4.webp',
    'images/tuk5.webp',
  ];

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

  Future<void> openMap(bool isStart) async {
    LatLng? selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(
          title: isStart ? "اختيار نقطة البداية" : "اختيار نقطة النهاية",
          initialPosition: isStart ? startLatLng : endLatLng,
          startPosition: startLatLng,
          endPosition: endLatLng,
        ),
      ),
    );
    if (selected != null) {
      setState(() {
        if (isStart) {
          startController.text = "جاري تحديد الموقع...";
        } else {
          endController.text = "جاري تحديد الموقع...";
        }
      });

      String place = await getPlaceName(selected.latitude, selected.longitude);

      setState(() {
        if (isStart) {
          startLatLng = selected;
          startController.text = place;
        } else {
          endLatLng = selected;
          endController.text = place;
        }
      });
    }
  }

  bool get isReady => startLatLng != null && endLatLng != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.orange),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        title: const Text(
          "Meshwarek",
          style: TextStyle(
            color: Colors.black,
            fontSize: 35,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            CarouselSlider(
              options: CarouselOptions(
                height: 240,
                autoPlay: true,
                enlargeCenterPage: true,
              ),
              items: images.map((imagePath) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 6,
                        offset: Offset(0, 4),
                      )
                    ],
                    image: DecorationImage(
                      image: AssetImage(imagePath),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 60),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  _buildInput(
                    controller: startController,
                    hint: "اختر نقطة البداية",
                    icon: Icons.map,
                    onTap: () => openMap(true),
                  ),
                  const SizedBox(height: 60),
                  _buildInput(
                    controller: endController,
                    hint: "اختر نقطة الوصول",
                    icon: Icons.location_on,
                    onTap: () => openMap(false),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  onPressed: (isReady && !_isUpdating)
                      ? () async {
                          setState(() => _isUpdating = true);
                          try {
                            // تحديث بيانات الموقع في Firestore
                            await _firestoreService.updateTripLocation(
                              tripId: widget.tripId,
                              startPlace: startController.text,
                              endPlace: endController.text,
                              startLat: startLatLng!.latitude,
                              startLng: startLatLng!.longitude,
                              endLat: endLatLng!.latitude,
                              endLng: endLatLng!.longitude,
                            );

                            if (mounted) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => MeetingScreen(
                                    tripId: widget.tripId,
                                    start: startLatLng!,
                                    end: endLatLng!,
                                    startPlaceName: startController.text,
                                    endPlaceName: endController.text,
                                  ),
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint("Error updating trip location: $e");
                          } finally {
                            if (mounted) setState(() => _isUpdating = false);
                          }
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isReady ? Colors.black : Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isUpdating
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "التالي",
                          style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 6),
          )
        ],
      ),
      padding: const EdgeInsets.all(12),
      child: TextFormField(
        controller: controller,
        readOnly: true,
        onTap: onTap,
        textAlign: TextAlign.center,
        maxLines: 3,
        style: const TextStyle(
          fontSize: 23,
          fontWeight: FontWeight.bold,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 23,
            color: Colors.black,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(18),
          suffixIcon: Icon(icon, color: Colors.black, size: 30),
        ),
      ),
    );
  }
}

class MapPickerScreen extends StatefulWidget {
  final String title;
  final LatLng? initialPosition;
  final LatLng? startPosition;
  final LatLng? endPosition;

  const MapPickerScreen({
    super.key,
    required this.title,
    this.initialPosition,
    this.startPosition,
    this.endPosition,
  });

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  LatLng? selectedPoint;

  @override
  void initState() {
    super.initState();
    selectedPoint = widget.initialPosition;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text(
          widget.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 35,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(50), // ripple دائري
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.black,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  )
                ],
              ),
              child: const Icon(
                Icons.arrow_back,
                color: Colors.orangeAccent, // لون السهم
                size: 30,
              ),
            ),
          ),
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: selectedPoint ??
              widget.startPosition ??
              const LatLng(30.0444, 31.2357),
          initialZoom: 13,
          onTap: (tap, point) => setState(() => selectedPoint = point),
        ),
        children: [
          TileLayer(
            urlTemplate:
                "https://api.maptiler.com/maps/streets/{z}/{x}/{y}.png?key=poneGPfuCb0jl0NnLfwb",
            userAgentPackageName: "com.example.tokgo",
          ),
          MarkerLayer(
            markers: [
              if (widget.startPosition != null)
                Marker(
                  point: widget.startPosition!,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.green,
                    size: 50,
                  ),
                ),
              if (widget.endPosition != null)
                Marker(
                  point: widget.endPosition!,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
              if (selectedPoint != null)
                Marker(
                  point: selectedPoint!,
                  width: 60,
                  height: 60,
                  child: const Icon(
                    Icons.location_pin,
                    color: Colors.red,
                    size: 50,
                  ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.large(
        backgroundColor: Colors.orange.shade400,
        onPressed: () {
          if (selectedPoint != null) {
            Navigator.pop(context, selectedPoint);
          }
        },
        child: const Icon(Icons.check, color: Colors.black, size: 40),
      ),
    );
  }
}
