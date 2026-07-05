import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../providers/destination_provider.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/models/hotel_model.dart';
import 'hotel_detail_screen.dart';

class HotelListingsScreen extends StatefulWidget {
  final DestinationModel destination;

  const HotelListingsScreen({super.key, required this.destination});

  @override
  State<HotelListingsScreen> createState() => _HotelListingsScreenState();
}

class _HotelListingsScreenState extends State<HotelListingsScreen> {
  List<HotelModel> _hotels = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHotels();
  }

  Future<void> _fetchHotels() async {
    final destProv = Provider.of<DestinationProvider>(context, listen: false);
    final hotelsList = await destProv.loadHotelsForDestination(widget.destination.id);
    if (mounted) {
      setState(() {
        _hotels = hotelsList;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          'Hotels in ${widget.destination.name}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
      ),
      body: _isLoading
          ? const ShimmerCardList(itemCount: 3, height: 120)
          : _hotels.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.hotel_class_outlined, size: 64, color: isDark ? AppColors.borderDark : Colors.grey),
                      const SizedBox(height: 12),
                      const Text(
                        'No hotels available here at this time.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20.0),
                  itemCount: _hotels.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final hotel = _hotels[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HotelDetailScreen(hotel: hotel),
                          ),
                        );
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(color: Color(0x0D000000), blurRadius: 8, offset: Offset(0, 3)),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                              child: CachedNetworkImage(
                                imageUrl: hotel.images[0],
                                width: 120,
                                height: 130,
                                fit: BoxFit.cover,
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            hotel.name,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            const Icon(Icons.star, color: AppColors.starRating, size: 14),
                                            const SizedBox(width: 2),
                                            Text(
                                              hotel.rating.toString(),
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      hotel.distanceFromCenter,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    // Amenities icons preview
                                    Row(
                                      children: hotel.amenities.take(3).map((ame) {
                                        IconData icon = Icons.check_circle_outline;
                                        if (ame.toLowerCase().contains('wifi')) icon = Icons.wifi_rounded;
                                        if (ame.toLowerCase().contains('pool')) icon = Icons.pool_rounded;
                                        if (ame.toLowerCase().contains('spa')) icon = Icons.spa_rounded;
                                        return Padding(
                                          padding: const EdgeInsets.only(right: 6.0),
                                          child: Icon(icon, size: 16, color: AppColors.primary),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          '\$${hotel.pricePerNight.toStringAsFixed(0)} / night',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                            color: AppColors.secondary,
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: const Text(
                                            'Book Now',
                                            style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
