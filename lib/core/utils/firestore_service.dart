import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // تسجيل رقم الهاتف وبدء رحلة جديدة
  Future<String> startTrip(String phoneNumber) async {
    DocumentReference docRef = await _db.collection('trips').add({
      'phone_number': phoneNumber,
      'status': 'started',
      'created_at': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // تحديث بيانات مكان الرحلة
  Future<void> updateTripLocation({
    required String tripId,
    required String startPlace,
    required String endPlace,
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) async {
    await _db.collection('trips').doc(tripId).update({
      'start_place': startPlace,
      'end_place': endPlace,
      'start_lat': startLat,
      'start_lng': startLng,
      'end_lat': endLat,
      'end_lng': endLng,
      'status': 'location_set',
    });
  }

  // تحديث مكان الالتقاء
  Future<void> updateMeetingPoint({
    required String tripId,
    required String meetingPlace,
    required double meetingLat,
    required double meetingLng,
  }) async {
    await _db.collection('trips').doc(tripId).update({
      'meeting_place': meetingPlace,
      'meeting_lat': meetingLat,
      'meeting_lng': meetingLng,
      'status': 'meeting_set',
    });
  }

  // تحديث بيانات السائق المختار
  Future<void> selectDriver({
    required String tripId,
    required String driverName,
    required String driverPhone,
    required String driverPrice,
  }) async {
    await _db.collection('trips').doc(tripId).update({
      'selected_driver_name': driverName,
      'selected_driver_phone': driverPhone,
      'trip_price': driverPrice,
      'status': 'driver_selected',
      'confirmed_at': FieldValue.serverTimestamp(),
    });
  }
}
