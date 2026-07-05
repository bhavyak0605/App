import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import 'trip_planner_screen.dart';
import 'trip_detail_screen.dart';

class MyTripsScreen extends StatelessWidget {
  const MyTripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tripProv = Provider.of<TripProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
        appBar: AppBar(
          title: const Text('My Trips', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit')),
          bottom: TabBar(
            indicatorColor: AppColors.primary,
            labelColor: AppColors.primary,
            unselectedLabelColor: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
            tabs: const [
              Tab(text: 'Upcoming'),
              Tab(text: 'Completed'),
              Tab(text: 'Cancelled'),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add_circle_outline_rounded, color: AppColors.primary, size: 28),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripPlannerScreen()),
                );
              },
            ),
          ],
        ),
        body: tripProv.isLoading
            ? const ShimmerCardList(itemCount: 3)
            : TabBarView(
                children: [
                  _buildTripList(context, tripProv.upcomingTrips, 'upcoming', isDark),
                  _buildTripList(context, tripProv.completedTrips, 'completed', isDark),
                  _buildTripList(context, tripProv.cancelledTrips, 'cancelled', isDark),
                ],
              ),
      ),
    );
  }

  Widget _buildTripList(BuildContext context, List trips, String status, bool isDark) {
    if (trips.isEmpty) {
      String description = 'You have no upcoming travel plans.';
      if (status == 'completed') description = 'You haven\'t completed any trips yet.';
      if (status == 'cancelled') description = 'No cancelled travel plans found.';

      return EmptyState(
        icon: Icons.card_travel_rounded,
        title: 'No Trips Found',
        description: description,
        actionText: status == 'upcoming' ? 'Create A Trip' : null,
        onActionPressed: status == 'upcoming'
            ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TripPlannerScreen()),
                );
              }
            : null,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      itemCount: trips.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final t = trips[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => TripDetailScreen(trip: t)),
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
                    imageUrl: t.destinationImage,
                    width: 100,
                    height: 110,
                    fit: BoxFit.cover,
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.destinationName,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Outfit'),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.date_range_rounded, size: 14, color: AppColors.primary),
                            const SizedBox(width: 4),
                            Text(
                              '${DateFormat('dd MMM').format(t.startDate)} - ${DateFormat('dd MMM yyyy').format(t.endDate)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Budget: \$${t.budget.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                                color: AppColors.primary,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _getStatusColor(t.status).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                t.status.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: _getStatusColor(t.status),
                                ),
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
    );
  }

  Color _getStatusColor(String status) {
    if (status == 'upcoming') return AppColors.info;
    if (status == 'completed') return AppColors.success;
    return AppColors.error;
  }
}
