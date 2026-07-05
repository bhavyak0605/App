import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/custom_button.dart';
import '../../providers/trip_provider.dart';
import '../../../data/models/trip_model.dart';
import 'trip_planner_screen.dart';

class TripDetailScreen extends StatefulWidget {
  final TripModel trip;

  const TripDetailScreen({super.key, required this.trip});

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  late TripModel _currentTrip;
  bool _isActionRunning = false;

  @override
  void initState() {
    super.initState();
    _currentTrip = widget.trip;
  }

  Future<void> _deleteTrip() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Trip'),
        content: const Text('Are you sure you want to delete this trip plan? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _isActionRunning = true);
      final tripProv = Provider.of<TripProvider>(context, listen: false);
      final success = await tripProv.deleteTrip(_currentTrip.id);
      
      if (mounted) {
        setState(() => _isActionRunning = false);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Trip deleted successfully.'), backgroundColor: AppColors.success),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  Future<void> _updateTripStatus(String newStatus) async {
    setState(() => _isActionRunning = true);
    final tripProv = Provider.of<TripProvider>(context, listen: false);
    final updatedTrip = _currentTrip.copyWith(status: newStatus);
    
    final success = await tripProv.updateTrip(updatedTrip);
    if (mounted) {
      setState(() {
        _isActionRunning = false;
        if (success) {
          _currentTrip = updatedTrip;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: _isActionRunning
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Image Header
                  Stack(
                    children: [
                      CachedNetworkImage(
                        imageUrl: _currentTrip.destinationImage,
                        height: size.height * 0.32,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        height: size.height * 0.32,
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.black54, Colors.transparent, Colors.black45],
                          ),
                        ),
                      ),
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
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TripPlannerScreen(editTrip: _currentTrip),
                                  ),
                                );
                                // Refresh current trip from provider database
                                final tripProv = Provider.of<TripProvider>(context, listen: false);
                                final matches = tripProv.trips.where((t) => t.id == _currentTrip.id);
                                if (matches.isNotEmpty) {
                                  setState(() {
                                    _currentTrip = matches.first;
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                                child: const Icon(Icons.edit_rounded, color: Colors.black, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        bottom: 20,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _currentTrip.destinationName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Outfit',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                _currentTrip.status.toUpperCase(),
                                style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // 2. Info Cards
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Details Badges Row
                        Row(
                          children: [
                            _buildInfoBadge(
                              context,
                              Icons.date_range_rounded,
                              'DURATION',
                              '${DateFormat('dd MMM').format(_currentTrip.startDate)} - ${DateFormat('dd MMM').format(_currentTrip.endDate)}',
                            ),
                            _buildInfoBadge(
                              context,
                              Icons.payments_rounded,
                              'BUDGET',
                              '\$${_currentTrip.budget.toStringAsFixed(0)}',
                            ),
                            _buildInfoBadge(
                              context,
                              Icons.people_rounded,
                              'TRAVELERS',
                              '${_currentTrip.travelers} Persons',
                            ),
                          ],
                        ),
                        const SizedBox(height: 28),

                        // 3. Notes section
                        Text(
                          'Trip Itinerary Notes',
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.surfaceDark : Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                          child: Text(
                            _currentTrip.notes.isNotEmpty ? _currentTrip.notes : 'No specific notes saved for this trip yet.',
                            style: TextStyle(
                              fontSize: 14,
                              height: 1.6,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ),
                        const SizedBox(height: 36),

                        // 4. Update status action options
                        if (_currentTrip.status == 'upcoming') ...[
                          Row(
                            children: [
                              Expanded(
                                child: CustomButton(
                                  text: 'Mark Completed',
                                  onPressed: () => _updateTripStatus('completed'),
                                  backgroundColor: AppColors.success,
                                  icon: Icons.check_rounded,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: CustomButton(
                                  text: 'Cancel Trip',
                                  onPressed: () => _updateTripStatus('cancelled'),
                                  isOutlined: true,
                                  textColor: AppColors.error,
                                  backgroundColor: AppColors.error,
                                  icon: Icons.cancel_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                        ],

                        // Delete button
                        CustomButton(
                          text: 'Delete Trip Record',
                          onPressed: _deleteTrip,
                          backgroundColor: Colors.transparent,
                          textColor: AppColors.error,
                          isOutlined: true,
                          icon: Icons.delete_outline_rounded,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildInfoBadge(BuildContext context, IconData icon, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isDark ? AppColors.borderDark : AppColors.borderLight),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
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
