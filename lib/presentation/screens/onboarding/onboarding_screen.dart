import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/widgets/custom_button.dart';
import '../auth/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<OnboardData> _slides = [
    OnboardData(
      title: AppStrings.obTitle1,
      description: AppStrings.obSub1,
      imageUrl: AppAssets.categoryBeach,
    ),
    OnboardData(
      title: AppStrings.obTitle2,
      description: AppStrings.obSub2,
      imageUrl: AppAssets.hotelFourSeasonsBali,
    ),
    OnboardData(
      title: AppStrings.obTitle3,
      description: AppStrings.obSub3,
      imageUrl: AppAssets.categoryMountain,
    ),
    OnboardData(
      title: AppStrings.obTitle4,
      description: AppStrings.obSub4,
      imageUrl: AppAssets.categoryForest,
    ),
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('ezztrip_onboarding_completed', true);
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      body: Stack(
        children: [
          // Background/Images and details
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: _slides.length,
            itemBuilder: (context, index) {
              final slide = _slides[index];
              return Column(
                children: [
                  // Visual header with gradient overlay
                  Expanded(
                    flex: 5,
                    child: Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: NetworkImage(slide.imageUrl),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                (isDark ? AppColors.backgroundDark : AppColors.backgroundLight).withOpacity(0.8),
                                isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Explanatory Text
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Text(
                            slide.title,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isDark ? AppColors.onBackgroundDark : AppColors.onBackgroundLight,
                                  fontFamily: 'Outfit',
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            slide.description,
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                                  fontFamily: 'Inter',
                                  height: 1.5,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          // Bottom Bar containing indicators and Skip/Next controls
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Page Indicator Dots
                Row(
                  children: List.generate(
                    _slides.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 6),
                      height: 8,
                      width: _currentIndex == index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: _currentIndex == index
                            ? AppColors.primary
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),

                // Controls
                Row(
                  children: [
                    if (_currentIndex < _slides.length - 1)
                      TextButton(
                        onPressed: _completeOnboarding,
                        child: Text(
                          AppStrings.skip,
                          style: TextStyle(
                            color: isDark ? AppColors.textMutedDark : AppColors.textMutedLight,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 12),
                    CustomButton(
                      text: _currentIndex == _slides.length - 1 ? AppStrings.getStarted : AppStrings.next,
                      onPressed: () {
                        if (_currentIndex < _slides.length - 1) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 450),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      width: _currentIndex == _slides.length - 1 ? 160 : 100,
                      height: 48,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardData {
  final String title;
  final String description;
  final String imageUrl;

  OnboardData({
    required this.title,
    required this.description,
    required this.imageUrl,
  });
}
