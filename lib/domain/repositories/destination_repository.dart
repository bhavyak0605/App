import '../../data/models/destination_model.dart';
import '../../data/models/category_model.dart';
import '../../data/models/banner_model.dart';
import '../../data/models/review_model.dart';
import '../../data/models/package_model.dart';

abstract class DestinationRepository {
  Future<List<DestinationModel>> getFeaturedDestinations();
  Future<List<DestinationModel>> getDestinationsByCategory(String categoryId);
  Future<List<DestinationModel>> searchDestinations(String query);
  Future<List<DestinationModel>> getAllDestinations();
  Future<List<ReviewModel>> getDestinationReviews(String destinationId);
  Future<List<CategoryModel>> getCategories();
  Future<List<BannerModel>> getBanners();
  Future<List<PackageModel>> getPackages();
}
