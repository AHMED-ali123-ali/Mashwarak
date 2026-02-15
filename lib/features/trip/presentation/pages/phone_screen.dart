import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/utils/firestore_service.dart';
import 'trip_screen.dart';

class PhoneScreen extends StatefulWidget {
  const PhoneScreen({super.key});

  @override
  State<PhoneScreen> createState() => _PhoneScreenState();
}

class _PhoneScreenState extends State<PhoneScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirestoreService _firestoreService = FirestoreService();
  late Timer _timer;
  double _scrollPosition = 0;
  bool _isSubmitting = false;

  final List<String> images = [
    'images/55.jpg',
    'images/66.jpg',
    'images/77.webp',
    'images/88.jpg',
    'images/tuk5.webp',
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 2), (timer) {
      if (_scrollController.hasClients) {
        _scrollPosition += 340;
        if (_scrollPosition >= _scrollController.position.maxScrollExtent) {
          _scrollPosition = 0;
        }
        _scrollController.animateTo(
          _scrollPosition,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _scrollController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  bool validatePhone(String value) {
    if (!value.startsWith('01')) return false;
    if (value.length != 11) return false;
    final numericRegex = RegExp(r'^[0-9]+$');
    if (!numericRegex.hasMatch(value)) return false;
    return true;
  }

  void showCustomSnackBar(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: color,
        duration: const Duration(seconds: 3),
        padding: const EdgeInsets.all(0),
        content: Container(
          width: double.infinity,
          height: 80,
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone, color: Colors.black, size: 28),
              const SizedBox(width: 10),
              Text(
                message,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageCard(String imagePath) {
    return Container(
      width: 340,
      height: 240,
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8,
            offset: Offset(0, 6),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: const Center(
          child: Text(
            "أدخل رقم الهاتف",
            style: TextStyle(
              fontSize: 35,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      ),
      backgroundColor: Colors.grey.shade100,
      body: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            height: 260,
            margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: ListView(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              children: images.map((img) => _buildImageCard(img)).toList(),
            ),
          ),
          const SizedBox(height: 50),
          Expanded(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "أدخل رقم الهاتف",
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(
                              fontSize: 40,
                              color: Colors.black87,
                              fontWeight: FontWeight.bold,
                            ),
                            decoration: InputDecoration(
                              labelText: "رقم الهاتف",
                              labelStyle: const TextStyle(
                                fontSize: 22,
                                color: Colors.black,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black54,
                                  width: 2,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: Colors.black,
                                  width: 2,
                                ),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade100,
                              prefixIcon: const Icon(
                                Icons.phone,
                                color: Colors.black87,
                                size: 30,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                    SizedBox(
                      width: double.infinity,
                      height: 70,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _isSubmitting
                            ? null
                            : () async {
                                String phone = _phoneController.text.trim();
                                if (phone.isEmpty) {
                                  showCustomSnackBar("من فضلك أدخل رقم الهاتف",
                                      color: Colors.orange);
                                } else if (!validatePhone(phone)) {
                                  showCustomSnackBar(
                                    "من فضلك ادخل رقم صحيح",
                                    color: Colors.red,
                                  );
                                } else {
                                  setState(() => _isSubmitting = true);
                                  try {
                                    // تسجيل الرقم والحصول على ID الرحلة
                                    String tripId = await _firestoreService
                                        .startTrip(phone);
                                    if (mounted) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TripScreen(
                                                tripId: tripId)),
                                      );
                                    }
                                  } catch (e) {
                                    showCustomSnackBar(
                                        "خطأ في الاتصال بالسيرفر");
                                  } finally {
                                    if (mounted) {
                                      setState(() => _isSubmitting = false);
                                    }
                                  }
                                }
                              },
                        child: _isSubmitting
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text(
                                "التالي",
                                style: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
