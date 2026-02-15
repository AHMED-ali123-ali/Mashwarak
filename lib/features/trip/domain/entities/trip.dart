import 'package:latlong2/latlong.dart';

class Trip {
  final String startPlace;
  final String endPlace;
  final String meetingPlace;
  final LatLng startLatLng;
  final LatLng meetingLatLng;
  final LatLng endLatLng;

  Trip({
    required this.startPlace,
    required this.endPlace,
    required this.meetingPlace,
    required this.startLatLng,
    required this.meetingLatLng,
    required this.endLatLng,
  });
}
