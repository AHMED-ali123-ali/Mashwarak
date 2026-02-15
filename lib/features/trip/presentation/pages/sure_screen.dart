import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../../../driver/presentation/pages/drivers_screen.dart';

class SureScreen extends StatelessWidget {
  final String tripId;
  final String startPlace;
  final String endPlace;
  final String meetingPlace;

  final LatLng startLatLng;
  final LatLng meetingLatLng;
  final LatLng endLatLng;

  const SureScreen({
    super.key,
    required this.tripId,
    required this.startPlace,
    required this.endPlace,
    required this.meetingPlace,
    required this.startLatLng,
    required this.meetingLatLng,
    required this.endLatLng,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: Colors.black,
            child: IconButton(
              icon: const Icon(Icons.arrow_back,
                  color: Colors.orangeAccent, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          "تأكيد البيانات",
          style: TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold, fontSize: 35),
        ),
      ),
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 25, vertical: 35),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildTimelineItem(
                      icon: Icons.location_on,
                      color: Colors.redAccent,
                      title: "نقطة البداية",
                      address: startPlace,
                    ),
                    _buildTimelineItem(
                      icon: Icons.person_pin_circle,
                      color: Colors.blueAccent,
                      title: "مكان الالتقاء",
                      address: meetingPlace,
                    ),
                    _buildTimelineItem(
                      icon: Icons.location_on,
                      color: Colors.green,
                      title: "نقطة النهاية",
                      address: endPlace,
                      isLast: true,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(25.0),
            child: _buildNextButton(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem({
    required IconData icon,
    required Color color,
    required String title,
    required String address,
    bool isLast = false,
  }) {
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 70,
                height: 110,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: color.withOpacity(0.4), width: 2),
                ),
                child: Icon(icon, color: color, size: 40),
              ),
              if (!isLast)
                SizedBox(
                  height: 100,
                  child: Container(
                    width: 7,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 25),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 27,
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  address,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (!isLast) const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 65,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Colors.black,
      ),
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DriversScreen(
                tripId: tripId,
                startPlace: startPlace,
                endPlace: endPlace,
                meetingPlace: meetingPlace,
                startLatLng: startLatLng,
                meetingLatLng: meetingLatLng,
                endLatLng: endLatLng,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        ),
        child: const Text(
          "تأكيد",
          style: TextStyle(
              fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
