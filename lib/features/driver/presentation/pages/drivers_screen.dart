import 'package:flutter/material.dart';
import 'dart:async';
import 'package:latlong2/latlong.dart';
import '../../../../core/utils/firestore_service.dart';
import 'ride_screen.dart';

class DriversScreen extends StatefulWidget {
  final String tripId;
  final String startPlace;
  final String endPlace;
  final String meetingPlace;

  final LatLng startLatLng;
  final LatLng meetingLatLng;
  final LatLng endLatLng;

  const DriversScreen({
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
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  bool isLoading = true;
  final FirestoreService _firestoreService = FirestoreService();

  final List<Map<String, dynamic>> drivers = [
    {
      "name": "أحمد محمد",
      "phone": "01290123456",
      "price": "20",
      "rating": "4.9",
      "img": "images/d1.jpg",
      "isSelecting": false,
    },
    {
      "name": "محمود سعد",
      "phone": "01234567890",
      "price": "25",
      "rating": "4.8",
      "img": "images/d2.webp",
      "isSelecting": false,
    },
    {
      "name": "سيد جابر",
      "phone": "01122334455",
      "price": "15",
      "rating": "4.6",
      "img": "images/d3.webp",
      "isSelecting": false,
    },
    {
      "name": "علي حسن",
      "phone": "01099887766",
      "price": "30",
      "rating": "4.7",
      "img": "images/d4.webp",
      "isSelecting": false,
    },
  ];

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 5), () {
      if (mounted) setState(() => isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade300,
      appBar: AppBar(
        title: const Text(
          "اختر سائقك",
          style: TextStyle(
              fontWeight: FontWeight.bold, fontSize: 35, color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: isLoading ? _buildLoadingScreen() : _buildDriversList(),
    );
  }

  Widget _buildLoadingScreen() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
              width: 120,
              height: 120,
              child: CircularProgressIndicator(
                  color: Colors.black, strokeWidth: 8)),
          SizedBox(height: 20),
          Text(
            "جاري البحث عن أقرب سائقين...",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDriversList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 10),
      itemCount: drivers.length,
      itemBuilder: (context, index) {
        final driver = drivers[index];
        return _buildDriverCard(driver, index);
      },
    );
  }

  Widget _buildDriverCard(Map<String, dynamic> driver, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 6))
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 40,
                backgroundImage: AssetImage(driver['img']),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      driver['name'],
                      style: const TextStyle(
                          fontSize: 25, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "📞 ${driver['phone']}",
                      style: const TextStyle(
                          fontSize: 18,
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 23),
                        const SizedBox(width: 5),
                        Text(
                          driver['rating'],
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  const Text(
                    "السعر",
                    style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "${driver['price']} ج",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: (driver['isSelecting'] ?? false)
                  ? null
                  : () async {
                      setState(() {
                        drivers[index]['isSelecting'] = true;
                      });
                      try {
                        // تحديث بيانات السائق في Firestore
                        await _firestoreService.selectDriver(
                          tripId: widget.tripId,
                          driverName: driver['name'],
                          driverPhone: driver['phone'],
                          driverPrice: driver['price'],
                        );

                        if (mounted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RideScreen(
                                startPlace: widget.startPlace,
                                endPlace: widget.endPlace,
                                meetingPlace: widget.meetingPlace,
                                startPlaceLatLng: widget.startLatLng,
                                meetingLatLng: widget.meetingLatLng,
                                endPlaceLatLng: widget.endLatLng,
                                driverName: driver['name'],
                                driverPhone: driver['phone'],
                                driverImage: driver['img'],
                                driverPrice: driver['price'],
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        debugPrint("Error selecting driver: $e");
                      } finally {
                        if (mounted) {
                          setState(() {
                            drivers[index]['isSelecting'] = false;
                          });
                        }
                      }
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
              ),
              child: (driver['isSelecting'] ?? false)
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "تأكيد",
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
