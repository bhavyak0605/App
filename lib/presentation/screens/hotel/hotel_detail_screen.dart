import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../../data/models/hotel_model.dart';
import '../../../data/models/booking_model.dart';
import '../../../data/repositories/service_locator.dart';

class HotelDetailScreen extends StatefulWidget {
  final HotelModel hotel;

  const HotelDetailScreen({super.key, required this.hotel});

  @override
  State<HotelDetailScreen> createState() => _HotelDetailScreenState();
}

class _HotelDetailScreenState extends State<HotelDetailScreen> {
  int _activeImageIndex = 0;
  DateTime _checkInDate = DateTime.now().add(const Duration(days: 1));
  DateTime _checkOutDate = DateTime.now().add(const Duration(days: 3));
  int _guests = 1;
  bool _isBooking = false;

  int get _nights => _checkOutDate.difference(_checkInDate).inDays;
  double get _totalPrice => widget.hotel.pricePerNight * _nights;

  Future<void> _selectCheckInDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkInDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkInDate) {
      setState(() {
        _checkInDate = picked;
        if (_checkOutDate.isBefore(_checkInDate) || _checkOutDate.isAtSameMomentAs(_checkInDate)) {
          _checkOutDate = _checkInDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectCheckOutDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _checkOutDate,
      firstDate: _checkInDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _checkOutDate) {
      setState(() {
        _checkOutDate = picked;
      });
    }
  }

  Future<void> _confirmBooking() async {
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    if (!authProv.isAuthenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to complete booking.')),
      );
      return;
    }

    setState(() {
      _isBooking = true;
    });

    try {
      final newBooking = BookingModel(
        id: '', // Will be set by repository
        userId: authProv.user!.id,
        hotelId: widget.hotel.id,
        hotelName: widget.hotel.name,
        hotelImage: widget.hotel.images[0],
        checkInDate: _checkInDate,
        checkOutDate: _checkOutDate,
        totalPrice: _totalPrice,
        guestCount: _guests,
        status: 'confirmed',
        createdAt: DateTime.now(),
      );

      await locator.bookingRepository.createBooking(newBooking);

      // Trigger Simulated Notification
      NotificationService().simulateNotification(
        title: 'Booking Confirmed! 🏨',
        body: 'Your reservation at ${widget.hotel.name} is complete for ${DateFormat('MMM dd').format(_checkInDate)} - ${DateFormat('MMM dd').format(_checkOutDate)}.',
        type: 'booking',
      );

      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Booking Successful!', textAlign: TextAlign.center),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.check_circle_rounded, color: AppColors.success, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'You have booked ${widget.hotel.name} successfully.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Paid: \$${_totalPrice.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context); // Go back to listings
                      Navigator.pop(context); // Go back to details
                    },
                    child: const Text('Back to Home'),
                  ),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Booking failed: $e'), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isBooking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final fav = Provider.of<FavoritesProvider>(context);
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
    final isSaved = fav.isHotelFav(widget.hotel.id);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Large Image Carousel Header
            Stack(
              children: [
                SizedBox(
                  height: size.height * 0.38,
                  child: PageView.builder(
                    onPageChanged: (idx) {
                      setState(() {
                        _activeImageIndex = idx;
                      });
                    },
                    itemCount: widget.hotel.images.length,
                    itemBuilder: (context, index) {
                      return CachedNetworkImage(
                        imageUrl: widget.hotel.images[index],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      );
                    },
                  ),
                ),
                // Shadow Gradient
                Container(
                  height: size.height * 0.38,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.black45, Colors.transparent, Colors.black26],
                    ),
                  ),
                ),
                // Navigation Buttons
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  left: 20,
                  right: 20,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Icon(Icons.arrow_back_rounded, color: Colors.black),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (userId.isNotEmpty) {
                            fav.toggleHotelFav(userId, widget.hotel.id);
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: Icon(
                            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                            color: isSaved ? AppColors.error : Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Dots Carousel Indicators
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.hotel.images.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _activeImageIndex == index ? 16 : 6,
                        decoration: BoxDecoration(
                          color: _activeImageIndex == index ? Colors.white : Colors.white70,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // 2. Info Core section
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.hotel.name,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.hotel.distanceFromCenter,
                              style: TextStyle(
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.starRating, size: 20),
                            const SizedBox(width: 4),
                            Text(
                              widget.hotel.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 3. Amenities
                  Text(
                    'Amenities Offered',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 12),
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 4,
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                    ),
                    itemCount: widget.hotel.amenities.length,
                    itemBuilder: (context, index) {
                      final ame = widget.hotel.amenities[index];
                      IconData icon = Icons.check_circle_outline_rounded;
                      if (ame.toLowerCase().contains('wifi')) icon = Icons.wifi_rounded;
                      if (ame.toLowerCase().contains('pool')) icon = Icons.pool_rounded;
                      if (ame.toLowerCase().contains('spa')) icon = Icons.spa_rounded;
                      if (ame.toLowerCase().contains('restaurant')) icon = Icons.restaurant_rounded;
                      if (ame.toLowerCase().contains('bar')) icon = Icons.local_bar_rounded;
                      if (ame.toLowerCase().contains('gym')) icon = Icons.fitness_center_rounded;

                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.grey[100],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(icon, size: 18, color: AppColors.primary),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                ame,
                                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // 4. Map Card
                  Text(
                    'Stays Location Map',
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: SizedBox(
                      height: 180,
                      width: double.infinity,
                      child: Stack(
                        children: [
                          GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(widget.hotel.latitude, widget.hotel.longitude),
                              zoom: 13,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(widget.hotel.id),
                                position: LatLng(widget.hotel.latitude, widget.hotel.longitude),
                                infoWindow: InfoWindow(title: widget.hotel.name),
                              ),
                            },
                            mapType: MapType.normal,
                            liteModeEnabled: true,
                            zoomControlsEnabled: false,
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                LocationService().openMapNavigation(
                                  widget.hotel.latitude,
                                  widget.hotel.longitude,
                                  widget.hotel.name,
                                );
                              },
                              icon: const Icon(Icons.navigation_rounded, size: 16),
                              label: const Text('Open Maps'),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                minimumSize: Size.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  // 5. Booking reservation widget Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.surfaceDark : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      boxShadow: const [
                        BoxShadow(color: Color(0x05000000), blurRadius: 10, offset: Offset(0, 4)),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Book Reservation',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        const SizedBox(height: 16),

                        // Date Pickers
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectCheckInDate,
                                child: _buildDateBox('CHECK IN', _checkInDate),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GestureDetector(
                                onTap: _selectCheckOutDate,
                                child: _buildDateBox('CHECK OUT', _checkOutDate),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Guests Counter
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GUESTS',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$_guests ${_guests == 1 ? "Guest" : "Guests"}',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: _guests > 1
                                      ? () => setState(() => _guests--)
                                      : null,
                                  icon: const Icon(Icons.remove_circle_outline_rounded),
                                  color: AppColors.primary,
                                ),
                                Text(
                                  '$_guests',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                                IconButton(
                                  onPressed: _guests < 10
                                      ? () => setState(() => _guests++)
                                      : null,
                                  icon: const Icon(Icons.add_circle_outline_rounded),
                                  color: AppColors.primary,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Price details breakdown
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '\$${widget.hotel.pricePerNight.toStringAsFixed(0)} x $_nights nights',
                              style: TextStyle(
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                            Text(
                              '\$${_totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Total Price', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            Text(
                              '\$${_totalPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.secondary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Booking button action
                        CustomButton(
                          text: 'Confirm Booking',
                          onPressed: _confirmBooking,
                          isLoading: _isBooking,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDateBox(String label, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.backgroundDark : Colors.grey[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 6),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
