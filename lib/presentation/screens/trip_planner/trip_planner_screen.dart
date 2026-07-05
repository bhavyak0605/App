import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../providers/auth_provider.dart';
import '../../providers/trip_provider.dart';
import '../../../data/models/destination_model.dart';
import '../../../data/models/trip_model.dart';
import '../../../data/repositories/service_locator.dart';

class TripPlannerScreen extends StatefulWidget {
  final DestinationModel? preSelectedDestination;
  final TripModel? editTrip; // If editing an existing trip

  const TripPlannerScreen({
    super.key,
    this.preSelectedDestination,
    this.editTrip,
  });

  @override
  State<TripPlannerScreen> createState() => _TripPlannerScreenState();
}

class _TripPlannerScreenState extends State<TripPlannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _budgetController = TextEditingController();
  final _notesController = TextEditingController();
  
  DestinationModel? _selectedDestination;
  List<DestinationModel> _allDestinations = [];
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 12));
  int _travelersCount = 1;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedDestination = widget.preSelectedDestination;
    
    if (widget.editTrip != null) {
      final trip = widget.editTrip!;
      _startDate = trip.startDate;
      _endDate = trip.endDate;
      _travelersCount = trip.travelers;
      _budgetController.text = trip.budget.toStringAsFixed(0);
      _notesController.text = trip.notes;
    }

    _loadDestinations();
  }

  Future<void> _loadDestinations() async {
    try {
      final list = await locator.destinationRepository.getAllDestinations();
      setState(() {
        _allDestinations = list;
        if (widget.editTrip != null) {
          try {
            _selectedDestination = _allDestinations.firstWhere((d) => d.id == widget.editTrip!.destinationId);
          } catch (_) {}
        }
      });
    } catch (e) {
      print("Error loading destinations: $e");
    }
  }

  @override
  void dispose() {
    _budgetController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate.isBefore(_startDate) || _endDate.isAtSameMomentAs(_startDate)) {
          _endDate = _startDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _saveTrip() async {
    if (_selectedDestination == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a destination.')),
      );
      return;
    }

    if (_formKey.currentState!.validate()) {
      final authProv = Provider.of<AuthProvider>(context, listen: false);
      final tripProv = Provider.of<TripProvider>(context, listen: false);

      if (!authProv.isAuthenticated) return;

      setState(() {
        _isLoading = true;
      });

      final budget = double.tryParse(_budgetController.text.trim()) ?? 0.0;

      final trip = TripModel(
        id: widget.editTrip?.id ?? '',
        userId: authProv.user!.id,
        destinationId: _selectedDestination!.id,
        destinationName: _selectedDestination!.name,
        destinationImage: _selectedDestination!.images[0],
        startDate: _startDate,
        endDate: _endDate,
        budget: budget,
        travelers: _travelersCount,
        notes: _notesController.text.trim(),
        status: widget.editTrip?.status ?? 'upcoming',
      );

      bool success;
      if (widget.editTrip != null) {
        success = await tripProv.updateTrip(trip);
      } else {
        success = await tripProv.createTrip(trip);
        if (success) {
          // Trigger push reminder notification simulation
          NotificationService().simulateNotification(
            title: 'Trip Created! ✈️',
            body: 'Get ready! Your trip to ${_selectedDestination!.name} starts on ${DateFormat('MMM dd').format(_startDate)}.',
            type: 'trip',
          );
        }
      }

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.editTrip != null ? 'Trip updated successfully!' : 'Trip created successfully!'),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(tripProv.errorMessage ?? 'Failed to save trip.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.editTrip != null ? 'Edit Trip' : 'Create Custom Trip',
          style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Destination Selection
                const Text(
                  'Choose Destination',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                widget.preSelectedDestination != null
                    ? Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.grey[200],
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.location_on_rounded, color: AppColors.primary),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDestination!.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.surfaceDark : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: isDark ? AppColors.borderDark : AppColors.borderLight,
                          ),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<DestinationModel>(
                            value: _selectedDestination,
                            hint: const Text('Select a city'),
                            isExpanded: true,
                            dropdownColor: isDark ? AppColors.surfaceDark : Colors.white,
                            style: TextStyle(
                              color: isDark ? Colors.white : Colors.black,
                              fontSize: 15,
                            ),
                            items: _allDestinations.map((d) {
                              return DropdownMenuItem<DestinationModel>(
                                value: d,
                                child: Text('${d.name}, ${d.city}'),
                              );
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                _selectedDestination = val;
                              });
                            },
                          ),
                        ),
                      ),
                const SizedBox(height: 20),

                // 2. Date Selection (Start and End)
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectStartDate,
                        child: _buildDateInputBox('START DATE', _startDate),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: _selectEndDate,
                        child: _buildDateInputBox('END DATE', _endDate),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 3. Travelers Counter
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Travelers', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        const SizedBox(height: 4),
                        Text(
                          '$_travelersCount ${_travelersCount == 1 ? "Traveler" : "Travelers"}',
                          style: TextStyle(
                            fontSize: 13,
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: _travelersCount > 1
                              ? () => setState(() => _travelersCount--)
                              : null,
                          icon: const Icon(Icons.remove_circle_outline_rounded),
                          color: AppColors.primary,
                        ),
                        Text(
                          '$_travelersCount',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: _travelersCount < 10
                              ? () => setState(() => _travelersCount++)
                              : null,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // 4. Budget Text input
                CustomTextField(
                  controller: _budgetController,
                  labelText: 'Estimated Budget (\$)',
                  hintText: 'e.g. 1500',
                  prefixIcon: Icons.payments_outlined,
                  keyboardType: TextInputType.number,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Please enter a budget amount.';
                    }
                    if (double.tryParse(val.trim()) == null) {
                      return 'Please enter a valid number.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // 5. Notes text field
                CustomTextField(
                  controller: _notesController,
                  labelText: 'Trip Notes / Itinerary plans',
                  hintText: 'e.g. Visit museums, try traditional meals, take lots of pictures!',
                  prefixIcon: Icons.note_alt_outlined,
                  maxLines: 4,
                ),
                const SizedBox(height: 36),

                // Save button
                CustomButton(
                  text: widget.editTrip != null ? 'Update Trip Plan' : 'Save Trip Plan',
                  onPressed: _saveTrip,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDateInputBox(String label, DateTime date) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
        ),
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
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.calendar_today_rounded, size: 14, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                DateFormat('dd MMM yyyy').format(date),
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
