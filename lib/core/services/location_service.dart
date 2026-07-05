import 'dart:math' as math;
import 'package:url_launcher/url_launcher.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  /// Launches Google Maps with navigation query to specified coordinates
  Future<bool> openMapNavigation(double latitude, double longitude, String label) async {
    final String googleMapsUrl = 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    final Uri uri = Uri.parse(googleMapsUrl);
    
    try {
      if (await canLaunchUrl(uri)) {
        return await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return false;
    } catch (e) {
      print("Could not launch maps: $e");
      return false;
    }
  }

  /// Simple calculation of distance (in km) between two coordinates using the Haversine formula
  double calculateDistance(double startLat, double startLng, double endLat, double endLng) {
    // Standard Haversine distance
    var p = 0.017453292519943295; // Math.PI / 180
    var a = 0.5 -
        math.cos((endLat - startLat) * p) / 2 +
        math.cos(startLat * p) * math.cos(endLat * p) * (1 - math.cos((endLng - startLng) * p)) / 2;
    
    return 12742 * math.asin(math.sqrt(a)); // 2 * R; R = 6371 km
  }
}
