import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class FirebaseBookingRepository implements BookingRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    final docRef = _firestore.collection('bookings').doc();
    final newBooking = BookingModel(
      id: docRef.id,
      userId: booking.userId,
      hotelId: booking.hotelId,
      hotelName: booking.hotelName,
      hotelImage: booking.hotelImage,
      checkInDate: booking.checkInDate,
      checkOutDate: booking.checkOutDate,
      totalPrice: booking.totalPrice,
      guestCount: booking.guestCount,
      status: 'confirmed',
      createdAt: DateTime.now(),
    );
    await docRef.set(newBooking.toMap());
    return newBooking;
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    final querySnapshot = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await _firestore.collection('bookings').doc(bookingId).update({
      'status': 'cancelled',
    });
  }
}
