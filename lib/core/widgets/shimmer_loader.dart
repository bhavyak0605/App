import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../constants/app_colors.dart';

class ShimmerLoader extends StatelessWidget {
  final double width;
  final double height;
  final ShapeBorder shapeBorder;

  const ShimmerLoader.rectangular({
    super.key,
    this.width = double.infinity,
    required this.height,
    this.shapeBorder = const RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(12)),
    ),
  });

  const ShimmerLoader.circular({
    super.key,
    required double size,
    this.shapeBorder = const CircleBorder(),
  })  : width = size,
        height = size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Shimmer.fromColors(
      baseColor: isDark ? AppColors.borderDark : Colors.grey[300]!,
      highlightColor: isDark ? AppColors.surfaceDark : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: ShapeDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.grey[400]!,
          shape: shapeBorder,
        ),
      ),
    );
  }
}

class ShimmerCardList extends StatelessWidget {
  final int itemCount;
  final double height;

  const ShimmerCardList({
    super.key,
    this.itemCount = 3,
    this.height = 140,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            ShimmerLoader.rectangular(
              width: 100,
              height: height,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const ShimmerLoader.rectangular(height: 20, width: 150),
                  const SizedBox(height: 8),
                  const ShimmerLoader.rectangular(height: 14, width: 220),
                  const SizedBox(height: 8),
                  Row(
                    children: const [
                      ShimmerLoader.circular(size: 24),
                      SizedBox(width: 8),
                      ShimmerLoader.rectangular(height: 14, width: 80),
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
}
