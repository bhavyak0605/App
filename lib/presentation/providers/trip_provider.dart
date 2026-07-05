import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import '../../data/repositories/service_locator.dart';

class TripProvider extends ChangeNotifier {
  List<TripModel> _trips = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<TripModel> get trips => _trips;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<TripModel> get upcomingTrips => _trips.where((t) => t.status == 'upcoming').toList();
  List<TripModel> get completedTrips => _trips.where((t) => t.status == 'completed').toList();
  List<TripModel> get cancelledTrips => _trips.where((t) => t.status == 'cancelled').toList();

  Future<void> loadTrips(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _trips = await locator.tripRepository.getUserTrips(userId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
    }
  }

  Future<bool> createTrip(TripModel trip) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newTrip = await locator.tripRepository.createTrip(trip);
      _trips.add(newTrip);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTrip(TripModel trip) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updated = await locator.tripRepository.updateTrip(trip);
      final index = _trips.indexWhere((t) => t.id == trip.id);
      if (index != -1) {
        _trips[index] = updated;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTrip(String tripId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await locator.tripRepository.deleteTrip(tripId);
      _trips.removeWhere((t) => t.id == tripId);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }
}
