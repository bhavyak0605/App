import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:share_plus/share_plus.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/location_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../providers/auth_provider.dart';
import '../../providers/destination_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/models/review_model.dart';
import '../hotel/hotel_listings_screen.dart';
import '../trip_planner/trip_planner_screen.dart';

class DestinationDetailScreen extends StatefulWidget {
  final DestinationModel destination;

  const DestinationDetailScreen({super.key, required this.destination});

  @override
  State<DestinationDetailScreen> createState() => _DestinationDetailScreenState();
}

class _DestinationDetailScreenState extends State<DestinationDetailScreen> {
  int _activeImageIndex = 0;
  List<ReviewModel> _reviews = [];
  bool _isLoadingReviews = true;

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    final destProv = Provider.of<DestinationProvider>(context, listen: false);
    final reviewsList = await destProv.loadDestinationReviews(widget.destination.id);
    if (mounted) {
      setState(() {
        _reviews = reviewsList;
        _isLoadingReviews = false;
      });
    }
  }

  void _shareDestination() {
    Share.share(
      'Check out this beautiful travel destination: ${widget.destination.name}, ${widget.destination.city}! Plan your trip on EzzTrip.',
      subject: 'Explore ${widget.destination.name} on EzzTrip',
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final fav = Provider.of<FavoritesProvider>(context);
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';
    final isSaved = fav.isDestFav(widget.destination.id);

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
                  height: size.height * 0.42,
                  child: PageView.builder(
                    onPageChanged: (idx) {
                      setState(() {
                        _activeImageIndex = idx;
                      });
                    },
                    itemCount: widget.destination.images.length,
                    itemBuilder: (context, index) {
                      return Hero(
                        tag: index == 0 ? 'dest_img_${widget.destination.id}' : 'dest_img_other_$index',
                        child: CachedNetworkImage(
                          imageUrl: widget.destination.images[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                        ),
                      );
                    },
                  ),
                ),
                // Gradient Shadow Overlay
                Container(
                  height: size.height * 0.42,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black54,
                        Colors.transparent,
                        Colors.black38,
                      ],
                    ),
                  ),
                ),
                // Navigation Overlay Buttons
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
                      Row(
                        children: [
                          GestureDetector(
                            onTap: _shareDestination,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                              child: const Icon(Icons.share_outlined, color: Colors.black, size: 20),
                            ),
                          ),
                          const SizedBox(width: 12),
                          GestureDetector(
                            onTap: () {
                              if (userId.isNotEmpty) {
                                fav.toggleDestinationFav(userId, widget.destination.id);
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
                    ],
                  ),
                ),
                // Dot indicator list overlay
                Positioned(
                  bottom: 16,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.destination.images.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        height: 6,
                        width: _activeImageIndex == index ? 16 : 6,
                        decoration: BoxDecoration(
                          color: _activeImageIndex == index ? Colors.white : Colors.white60,
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
                              widget.destination.name,
                              style: theme.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                                color: isDark ? Colors.white : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.location_on_rounded, color: AppColors.primary, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  widget.destination.city,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star_rounded, color: AppColors.starRating, size: 22),
                            const SizedBox(width: 4),
                            Text(
                              widget.destination.rating.toString(),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. Details Strip (Budget, Best time, Weather)
                  Row(
                    children: [
                      _buildDetailBadge(
                        context,
                        Icons.payments_outlined,
                        'Budget',
                        '\$${widget.destination.estimatedBudget.toStringAsFixed(0)}',
                      ),
                      _buildDetailBadge(
                        context,
                        Icons.wb_sunny_outlined,
                        'Weather',
                        '${widget.destination.weatherTemp} (${widget.destination.weatherCondition})',
                      ),
                      _buildDetailBadge(
                        context,
                        Icons.calendar_month_outlined,
                        'Best Visit',
                        widget.destination.bestTimeToVisit,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // 4. Description
                  Text(
                    'About Destination',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.destination.description,
                    style: TextStyle(
                      color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      fontSize: 15,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // 5. Popular Attractions
                  Text(
                    'Popular Attractions',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: widget.destination.attractions.map((att) {
                      return Chip(
                        label: Text(att),
                        avatar: const Icon(Icons.location_city_rounded, size: 16, color: AppColors.primary),
                        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
                        side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // 6. Map preview
                  Text(
                    'Location Map',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
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
                              target: LatLng(widget.destination.latitude, widget.destination.longitude),
                              zoom: 12,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId(widget.destination.id),
                                position: LatLng(widget.destination.latitude, widget.destination.longitude),
                                infoWindow: InfoWindow(title: widget.destination.name),
                              ),
                            },
                            mapType: MapType.normal,
                            liteModeEnabled: true, // Speeds up loading on mock maps
                            zoomControlsEnabled: false,
                          ),
                          // Overlay button to launch navigation
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: ElevatedButton.icon(
                              onPressed: () {
                                LocationService().openMapNavigation(
                                  widget.destination.latitude,
                                  widget.destination.longitude,
                                  widget.destination.name,
                                );
                              },
                              icon: const Icon(Icons.navigation_rounded, size: 16),
                              label: const Text('Navigate'),
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
                  const SizedBox(height: 24),

                  // 7. Reviews List
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Reviews (${_reviews.length})',
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _isLoadingReviews
                      ? const ShimmerLoader.rectangular(height: 80)
                      : _reviews.isEmpty
                          ? Center(
                              child: Text(
                                'No reviews yet. Be the first to add a review!',
                                style: TextStyle(color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight),
                              ),
                            )
                          : ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _reviews.length,
                              separatorBuilder: (context, index) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                final rev = _reviews[index];
                                return Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            radius: 18,
                                            backgroundImage: CachedNetworkImageProvider(
                                              rev.userPhoto.isNotEmpty ? rev.userPhoto : AppAssets.defaultProfileImage,
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(rev.userName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                                                Row(
                                                  children: List.generate(
                                                    5,
                                                    (idx) => Icon(
                                                      Icons.star,
                                                      size: 12,
                                                      color: idx < rev.rating.toInt() ? AppColors.starRating : Colors.grey,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        rev.text,
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: isDark ? AppColors.onBackgroundDark : AppColors.onBackgroundLight,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                  const SizedBox(height: 36),

                  // Actions Section
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => HotelListingsScreen(destination: widget.destination),
                              ),
                            );
                          },
                          icon: const Icon(Icons.hotel_rounded, size: 20),
                          label: const Text('Browse Hotels'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: CustomButton(
                          text: 'Plan A Trip',
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TripPlannerScreen(preSelectedDestination: widget.destination),
                              ),
                            );
                          },
                          icon: Icons.calendar_month_rounded,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailBadge(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
