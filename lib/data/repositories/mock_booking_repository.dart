import 'package:uuid/uuid.dart';
import '../../domain/repositories/booking_repository.dart';
import '../models/booking_model.dart';

class MockBookingRepository implements BookingRepository {
  final List<BookingModel> _bookings = [];
  final _uuid = const Uuid();

  @override
  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 1000));
    
    final newBooking = BookingModel(
      id: 'book_${_uuid.v4().substring(0, 8)}',
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

    _bookings.add(newBooking);
    return newBooking;
  }

  @override
  Future<List<BookingModel>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _bookings.where((b) => b.userId == userId).toList();
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 800));
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final old = _bookings[index];
      _bookings[index] = BookingModel(
        id: old.id,
        userId: old.userId,
        hotelId: old.hotelId,
        hotelName: old.hotelName,
        hotelImage: old.hotelImage,
        checkInDate: old.checkInDate,
        checkOutDate: old.checkOutDate,
        totalPrice: old.totalPrice,
        guestCount: old.guestCount,
        status: 'cancelled',
        createdAt: old.createdAt,
      );
    }
  }
}
