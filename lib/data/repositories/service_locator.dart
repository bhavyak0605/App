import 'package:firebase_core/firebase_core.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/booking_repository.dart';
import '../../domain/repositories/destination_repository.dart';
import '../../domain/repositories/favorites_repository.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../../domain/repositories/trip_repository.dart';

import 'mock_auth_repository.dart';
import 'mock_booking_repository.dart';
import 'mock_destination_repository.dart';
import 'mock_favorites_repository.dart';
import 'mock_hotel_repository.dart';
import 'mock_trip_repository.dart';

import 'firebase_auth_repository.dart';
import 'firebase_booking_repository.dart';
import 'firebase_destination_repository.dart';
import 'firebase_favorites_repository.dart';
import 'firebase_hotel_repository.dart';
import 'firebase_trip_repository.dart';

class ServiceLocator {
  static final ServiceLocator _instance = ServiceLocator._internal();
  factory ServiceLocator() => _instance;
  ServiceLocator._internal();

  bool _isFirebaseEnabled = false;
  bool get isFirebaseEnabled => _isFirebaseEnabled;

  late final AuthRepository authRepository;
  late final DestinationRepository destinationRepository;
  late final HotelRepository hotelRepository;
  late final BookingRepository bookingRepository;
  late final TripRepository tripRepository;
  late final FavoritesRepository favoritesRepository;

  Future<void> init() async {
    try {
      // Try to initialize Firebase
      await Firebase.initializeApp();
      _isFirebaseEnabled = true;
      print("Firebase successfully initialized! Active mode: Firebase Integration.");
    } catch (e) {
      _isFirebaseEnabled = false;
      print("Firebase initialize failed (No Google Services config found). Active mode: Mock Fallback.");
    }

    if (_isFirebaseEnabled) {
      authRepository = FirebaseAuthRepository();
      destinationRepository = FirebaseDestinationRepository();
      hotelRepository = FirebaseHotelRepository();
      bookingRepository = FirebaseBookingRepository();
      tripRepository = FirebaseTripRepository();
      favoritesRepository = FirebaseFavoritesRepository();
    } else {
      authRepository = MockAuthRepository();
      destinationRepository = MockDestinationRepository();
      hotelRepository = MockHotelRepository();
      bookingRepository = MockBookingRepository();
      tripRepository = MockTripRepository();
      favoritesRepository = MockFavoritesRepository();
    }
  }
}

// Global reference
final locator = ServiceLocator();
