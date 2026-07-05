import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../providers/auth_provider.dart';
import '../../providers/destination_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/models/hotel_model.dart';
import '../../../data/repositories/service_locator.dart';
import '../destination/destination_detail_screen.dart';
import '../hotel/hotel_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<HotelModel> _allHotels = [];
  bool _isLoadingHotels = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadAllHotels();
  }

  Future<void> _loadAllHotels() async {
    try {
      final list = await locator.hotelRepository.getAllHotels();
      if (mounted) {
        setState(() {
          _allHotels = list;
          _isLoadingHotels = false;
        });
      }
    } catch (e) {
      print("Error loading hotels in favorites screen: $e");
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final favProv = Provider.of<FavoritesProvider>(context);
    final destProv = Provider.of<DestinationProvider>(context);
    final userId = Provider.of<AuthProvider>(context, listen: false).user?.id ?? '';

    // Filter bookmarked Destinations
    final List<DestinationModel> favDestinations = destProv.featuredDestinations
        .where((d) => favProv.isDestFav(d.id))
        .toList();
        
    // Filter bookmarked Hotels
    final List<HotelModel> favHotels = _allHotels
        .where((h) => favProv.isHotelFav(h.id))
        .toList();

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('My Favorites', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primary,
          labelColor: AppColors.primary,
          unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
          tabs: const [
            Tab(text: 'Destinations', icon: Icon(Icons.place_rounded, size: 20)),
            Tab(text: 'Hotels', icon: Icon(Icons.hotel_rounded, size: 20)),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Destinations tab
          favProv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : favDestinations.isEmpty
                  ? const EmptyState(
                      icon: Icons.favorite_border_rounded,
                      title: 'No Favorite Destinations',
                      description: 'Start exploring and bookmark your top destinations to see them here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: favDestinations.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final d = favDestinations[index];
                        return _buildFavoriteItemCard(
                          context,
                          title: d.name,
                          subtitle: d.city,
                          imageUrl: d.images[0],
                          rating: d.rating,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => DestinationDetailScreen(destination: d)),
                            ).then((value) => favProv.loadFavorites(userId)); // Reload state on pop back
                          },
                          onRemove: () {
                            favProv.toggleDestinationFav(userId, d.id);
                          },
                        );
                      },
                    ),

          // Stays tab
          _isLoadingHotels || favProv.isLoading
              ? const Center(child: CircularProgressIndicator())
              : favHotels.isEmpty
                  ? const EmptyState(
                      icon: Icons.hotel_rounded,
                      title: 'No Favorite Hotels',
                      description: 'Browse hotels and save your preferred stays to view them here.',
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(20),
                      itemCount: favHotels.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final h = favHotels[index];
                        return _buildFavoriteItemCard(
                          context,
                          title: h.name,
                          subtitle: h.distanceFromCenter,
                          imageUrl: h.images[0],
                          rating: h.rating,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => HotelDetailScreen(hotel: h)),
                            ).then((value) => favProv.loadFavorites(userId));
                          },
                          onRemove: () {
                            favProv.toggleHotelFav(userId, h.id);
                          },
                        );
                      },
                    ),
        ],
      ),
    );
  }

  Widget _buildFavoriteItemCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String imageUrl,
    required double rating,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
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
                imageUrl: imageUrl,
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: onRemove,
                          child: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 20),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.starRating, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
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
  }
}
