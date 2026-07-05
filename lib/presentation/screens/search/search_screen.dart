import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/shimmer_loader.dart';
import '../../providers/destination_provider.dart';
import '../../providers/search_provider.dart';
import '../destination/destination_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Default search load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<SearchProvider>(context, listen: false).performSearch('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterSheet(BuildContext context) {
    final searchProv = Provider.of<SearchProvider>(context, listen: false);
    final destProv = Provider.of<DestinationProvider>(context, listen: false);
    
    double tempBudget = searchProv.maxBudget ?? 3000.0;
    double tempRating = searchProv.minRating ?? 1.0;
    String? tempCategoryId = searchProv.selectedCategoryId;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            
            return Padding(
              padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Filter Search',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
                      ),
                      TextButton(
                        onPressed: () {
                          setModalState(() {
                            tempBudget = 3000.0;
                            tempRating = 1.0;
                            tempCategoryId = null;
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                  const Divider(),
                  const SizedBox(height: 16),

                  // Budget range
                  Text(
                    'Max Budget: \$${tempBudget.toStringAsFixed(0)}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Slider(
                    value: tempBudget,
                    min: 200.0,
                    max: 3000.0,
                    divisions: 14,
                    activeColor: AppColors.primary,
                    onChanged: (val) {
                      setModalState(() {
                        tempBudget = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Minimum Rating
                  Text(
                    'Minimum Rating: ${tempRating.toStringAsFixed(1)} ★',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  Slider(
                    value: tempRating,
                    min: 1.0,
                    max: 5.0,
                    divisions: 8,
                    activeColor: AppColors.starRating,
                    onChanged: (val) {
                      setModalState(() {
                        tempRating = val;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Category Selector
                  const Text(
                    'Category',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: destProv.categories.map((cat) {
                      final isSelected = tempCategoryId == cat.id;
                      return ChoiceChip(
                        label: Text(cat.name),
                        selected: isSelected,
                        selectedColor: AppColors.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
                        ),
                        onSelected: (selected) {
                          setModalState(() {
                            tempCategoryId = selected ? cat.id : null;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  ElevatedButton(
                    onPressed: () {
                      searchProv.setFilters(
                        maxBudget: tempBudget,
                        minRating: tempRating,
                        categoryId: tempCategoryId,
                      );
                      searchProv.performSearch(_searchController.text);
                      Navigator.pop(context);
                    },
                    child: const Text('Apply Filters'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchProv = Provider.of<SearchProvider>(context);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Input Row
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onSubmitted: (query) {
                        searchProv.performSearch(query);
                      },
                      style: TextStyle(color: isDark ? Colors.white : Colors.black),
                      decoration: InputDecoration(
                        hintText: 'Search destinations...',
                        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded),
                                onPressed: () {
                                  _searchController.clear();
                                  searchProv.performSearch('');
                                },
                              )
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: () => _showFilterSheet(context),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.surfaceDark : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        ),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Recent searches tags
              if (searchProv.recentSearches.isNotEmpty && _searchController.text.isEmpty) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Recent Searches',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        searchProv.clearRecentSearches();
                      },
                      child: const Text('Clear All', style: TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: searchProv.recentSearches.map((term) {
                    return ActionChip(
                      label: Text(term, style: const TextStyle(fontSize: 13)),
                      backgroundColor: isDark ? AppColors.surfaceDark : Colors.grey[200],
                      onPressed: () {
                        _searchController.text = term;
                        searchProv.performSearch(term);
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
              ],

              // Results Label
              Text(
                'Search Results (${searchProv.searchResults.length})',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontFamily: 'Outfit'),
              ),
              const SizedBox(height: 12),

              // Search Results List
              Expanded(
                child: searchProv.isLoading
                    ? const ShimmerCardList(itemCount: 4)
                    : searchProv.searchResults.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.search_off_rounded, size: 64, color: isDark ? AppColors.borderDark : Colors.grey),
                                const SizedBox(height: 12),
                                const Text(
                                  'No results match your criteria.',
                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            itemCount: searchProv.searchResults.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 16),
                            itemBuilder: (context, index) {
                              final d = searchProv.searchResults[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DestinationDetailScreen(destination: d),
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
                                          imageUrl: d.images[0],
                                          width: 100,
                                          height: 100,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    d.name,
                                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                                  ),
                                                  Row(
                                                    children: [
                                                      const Icon(Icons.star, color: AppColors.starRating, size: 14),
                                                      const SizedBox(width: 2),
                                                      Text(
                                                        d.rating.toString(),
                                                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                d.city,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Text(
                                                'Budget: \$${d.estimatedBudget.toStringAsFixed(0)}',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 13,
                                                  color: AppColors.primary,
                                                ),
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
