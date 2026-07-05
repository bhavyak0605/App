import '../../data/models/booking_model.dart';

abstract class BookingRepository {
  Future<BookingModel> createBooking(BookingModel booking);
  Future<List<BookingModel>> getUserBookings(String userId);
  Future<void> cancelBooking(String bookingId);
}
