import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/repositories/destination_repository.dart';
import '../models/destination_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart';
import '../models/review_model.dart';
import '../models/package_model.dart';

class FirebaseDestinationRepository implements DestinationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<List<DestinationModel>> getFeaturedDestinations() async {
    final querySnapshot = await _firestore
        .collection('destinations')
        .where('isFeatured', isEqualTo: true)
        .get();
    return querySnapshot.docs.map((doc) => DestinationModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<DestinationModel>> getDestinationsByCategory(String categoryId) async {
    final querySnapshot = await _firestore
        .collection('destinations')
        .where('categoryId', isEqualTo: categoryId)
        .get();
    return querySnapshot.docs.map((doc) => DestinationModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<DestinationModel>> searchDestinations(String query) async {
    if (query.trim().isEmpty) return getAllDestinations();
    
    // Standard Firestore search uses prefixes
    final term = query.trim();
    final querySnapshot = await _firestore
        .collection('destinations')
        .where('name', isGreaterThanOrEqualTo: term)
        .where('name', isLessThanOrEqualTo: '$term\uf8ff')
        .get();
        
    return querySnapshot.docs.map((doc) => DestinationModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<DestinationModel>> getAllDestinations() async {
    final querySnapshot = await _firestore.collection('destinations').get();
    return querySnapshot.docs.map((doc) => DestinationModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<ReviewModel>> getDestinationReviews(String destinationId) async {
    final querySnapshot = await _firestore
        .collection('reviews')
        .where('destinationId', isEqualTo: destinationId)
        .orderBy('date', descending: true)
        .get();
    return querySnapshot.docs.map((doc) => ReviewModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    final querySnapshot = await _firestore.collection('categories').get();
    return querySnapshot.docs.map((doc) => CategoryModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    final querySnapshot = await _firestore.collection('banners').get();
    return querySnapshot.docs.map((doc) => BannerModel.fromFirestore(doc)).toList();
  }

  @override
  Future<List<PackageModel>> getPackages() async {
    final querySnapshot = await _firestore.collection('packages').get();
    return querySnapshot.docs.map((doc) => PackageModel.fromFirestore(doc)).toList();
  }
}
