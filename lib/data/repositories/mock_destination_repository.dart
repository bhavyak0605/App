import '../../core/constants/app_assets.dart';
import '../../domain/repositories/destination_repository.dart';
import '../models/destination_model.dart';
import '../models/category_model.dart';
import '../models/banner_model.dart';
import '../models/review_model.dart';
import '../models/package_model.dart';

class MockDestinationRepository implements DestinationRepository {
  // Mock Data In-Memory Cache
  final List<CategoryModel> _categories = [
    CategoryModel(id: 'cat_beaches', name: 'Beaches', imageUrl: AppAssets.categoryBeach, iconCode: 0xe0a0), // beach_access
    CategoryModel(id: 'cat_mountains', name: 'Mountains', imageUrl: AppAssets.categoryMountain, iconCode: 0xe66e), // terrain
    CategoryModel(id: 'cat_cities', name: 'Cities', imageUrl: AppAssets.categoryCity, iconCode: 0xe1ab), // location_city
    CategoryModel(id: 'cat_deserts', name: 'Deserts', imageUrl: AppAssets.categoryDesert, iconCode: 0xe194), // brightness_high / desert
    CategoryModel(id: 'cat_forests', name: 'Forests', imageUrl: AppAssets.categoryForest, iconCode: 0xe46c), // nature_people
  ];

  final List<BannerModel> _banners = [
    BannerModel(
      id: 'ban_1',
      title: 'Summer Getaways',
      subtitle: 'Up to 35% off on beach resorts',
      imageUrl: AppAssets.bannerSummerPromo,
      actionType: 'category',
      actionTarget: 'cat_beaches',
    ),
    BannerModel(
      id: 'ban_2',
      title: 'Asia Wonders',
      subtitle: 'Explore the heritage of Kyoto and Bali',
      imageUrl: AppAssets.bannerAsiaSpecial,
      actionType: 'destination',
      actionTarget: 'dest_kyoto',
    ),
    BannerModel(
      id: 'ban_3',
      title: 'Alpine Escapes',
      subtitle: 'Experience luxury in Swiss Alps',
      imageUrl: AppAssets.bannerEuropeExplorer,
      actionType: 'destination',
      actionTarget: 'dest_swiss_alps',
    ),
  ];

  final List<DestinationModel> _destinations = [
    DestinationModel(
      id: 'dest_paris',
      name: 'Paris',
      city: 'France',
      description: 'Paris, France\'s capital, is a major European city and a global center for art, fashion, gastronomy and culture. Its 19th-century cityscape is crisscrossed by wide boulevards and the River Seine. Beyond such landmarks as the Eiffel Tower and the 12th-century, Gothic Notre-Dame cathedral, the city is known for its cafe culture and designer boutiques along the Rue du Faubourg Saint-Honoré.',
      images: [
        AppAssets.destinationParis,
        'https://images.unsplash.com/photo-1511739001486-6bfe10ce785f?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1499856871958-5b9647a6406a?w=800&auto=format&fit=crop',
      ],
      weatherTemp: '18°C',
      weatherCondition: 'Cloudy',
      bestTimeToVisit: 'Apr - Jun',
      rating: 4.8,
      latitude: 48.8566,
      longitude: 2.3522,
      estimatedBudget: 1200.0,
      attractions: ['Eiffel Tower', 'Louvre Museum', 'Arc de Triomphe', 'Seine River Cruise'],
      isFeatured: true,
      categoryId: 'cat_cities',
    ),
    DestinationModel(
      id: 'dest_bali',
      name: 'Bali',
      city: 'Indonesia',
      description: 'Bali is an Indonesian island known for its forested volcanic mountains, iconic rice paddies, beaches and coral reefs. The island is home to religious sites such as cliffside Uluwatu Temple. To the south, the beachside city of Kuta has lively bars, while Seminyak, Sanur and Nusa Dua are popular resort towns. The island is also renowned for its yoga and meditation retreats.',
      images: [
        AppAssets.destinationBali,
        'https://images.unsplash.com/photo-1518235506717-e1ed3306a89b?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1538097304804-2a1b932466a9?w=800&auto=format&fit=crop',
      ],
      weatherTemp: '29°C',
      weatherCondition: 'Sunny',
      bestTimeToVisit: 'May - Sep',
      rating: 4.7,
      latitude: -8.4095,
      longitude: 115.1889,
      estimatedBudget: 600.0,
      attractions: ['Uluwatu Temple', 'Tegallalang Rice Terraces', 'Mount Batur', 'Seminyak Beach'],
      isFeatured: true,
      categoryId: 'cat_beaches',
    ),
    DestinationModel(
      id: 'dest_kyoto',
      name: 'Kyoto',
      city: 'Japan',
      description: 'Kyoto, once the capital of Japan, is a city on the island of Honshu. It\'s famous for its numerous classical Buddhist temples, as well as gardens, imperial palaces, Shinto shrines and traditional wooden houses. It\'s also known for formal traditions such as kaiseki dining, consisting of multiple courses of precise dishes, and geisha, female entertainers often found in the Gion district.',
      images: [
        AppAssets.destinationKyoto,
        'https://images.unsplash.com/photo-1493976040374-85c8e12f0c0e?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800&auto=format&fit=crop',
      ],
      weatherTemp: '21°C',
      weatherCondition: 'Sunny',
      bestTimeToVisit: 'Oct - Nov',
      rating: 4.9,
      latitude: 35.0116,
      longitude: 135.7681,
      estimatedBudget: 1500.0,
      attractions: ['Fushimi Inari Shrine', 'Kinkaku-ji (Golden Pavilion)', 'Arashiyama Bamboo Grove', 'Gion District'],
      isFeatured: true,
      categoryId: 'cat_cities',
    ),
    DestinationModel(
      id: 'dest_rome',
      name: 'Rome',
      city: 'Italy',
      description: 'Rome is the capital city and a special comune of Italy, as well as the capital of the Lazio region. The city has been a major human settlement for almost three millennia. With 2,860,009 residents in 1,285 km², it is also the country\'s most populated comune. It is the third most populous city in the European Union by population within city limits.',
      images: [
        AppAssets.destinationRome,
        'https://images.unsplash.com/photo-1515542690876-8799865437d7?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1529154036614-a60975f5c760?w=800&auto=format&fit=crop',
      ],
      weatherTemp: '24°C',
      weatherCondition: 'Sunny',
      bestTimeToVisit: 'Apr - Jun',
      rating: 4.6,
      latitude: 41.9028,
      longitude: 12.4964,
      estimatedBudget: 1100.0,
      attractions: ['Colosseum', 'Vatican Museums', 'Trevi Fountain', 'Pantheon'],
      isFeatured: false,
      categoryId: 'cat_cities',
    ),
    DestinationModel(
      id: 'dest_swiss_alps',
      name: 'Swiss Alps',
      city: 'Switzerland',
      description: 'The Alpine region of Switzerland, conventionally referred to as the Swiss Alps, represents a major natural feature of the country and is, along with the Swiss Plateau and the Swiss portion of the Jura Mountains, one of its three main physiographic regions.',
      images: [
        AppAssets.destinationSwissAlps,
        'https://images.unsplash.com/photo-1482862549707-f63cb32c5fd9?w=800&auto=format&fit=crop',
        'https://images.unsplash.com/photo-1464822759023-fed622ff2c3b?w=800&auto=format&fit=crop',
      ],
      weatherTemp: '8°C',
      weatherCondition: 'Snowy',
      bestTimeToVisit: 'Dec - Mar',
      rating: 4.9,
      latitude: 46.8182,
      longitude: 8.2275,
      estimatedBudget: 1800.0,
      attractions: ['Matterhorn', 'Jungfraujoch', 'Zermatt Ski Resort', 'Lake Geneva'],
      isFeatured: true,
      categoryId: 'cat_mountains',
    ),
  ];

  final List<PackageModel> _packages = [
    PackageModel(
      id: 'pkg_1',
      title: 'Romantic Paris Gateway',
      destinationId: 'dest_paris',
      description: 'Spend 5 memorable days in the city of love. Includes luxury accommodation, Eiffel Tower dinner, Louvre guided tour and private River Seine cruise.',
      price: 2499.0,
      rating: 4.8,
      durationDays: 5,
      images: [AppAssets.destinationParis],
    ),
    PackageModel(
      id: 'pkg_2',
      title: 'Bali Adventure & Retreat',
      destinationId: 'dest_bali',
      description: 'An 8-day trip combining exploration and wellness. Includes volcano hiking, temple visits, white river rafting, and 3 days of yoga retreats.',
      price: 1199.0,
      rating: 4.7,
      durationDays: 8,
      images: [AppAssets.destinationBali],
    ),
    PackageModel(
      id: 'pkg_3',
      title: 'Kyoto Cultural Discovery',
      destinationId: 'dest_kyoto',
      description: 'Dive deep into Japanese traditions. Enjoy tea ceremonies, stay in a traditional Ryokan, visit the top 5 shrines, and explore bamboo groves over 6 days.',
      price: 1899.0,
      rating: 4.9,
      durationDays: 6,
      images: [AppAssets.destinationKyoto],
    ),
  ];

  final Map<String, List<ReviewModel>> _reviews = {
    'dest_paris': [
      ReviewModel(
        id: 'rev_p1',
        userId: 'user_a',
        userName: 'Sophia Martinez',
        userPhoto: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&auto=format&fit=crop',
        rating: 5.0,
        text: 'Paris is absolutely stunning! The Eiffel tower at night was magical. Do try the local croissants near Montmartre.',
        date: DateTime.now().subtract(const Duration(days: 4)),
      ),
      ReviewModel(
        id: 'rev_p2',
        userId: 'user_b',
        userName: 'David Smith',
        userPhoto: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&auto=format&fit=crop',
        rating: 4.0,
        text: 'Amazing historical places, but extremely crowded. Be prepared to stand in long queues for Louvre.',
        date: DateTime.now().subtract(const Duration(days: 12)),
      ),
    ],
    'dest_bali': [
      ReviewModel(
        id: 'rev_b1',
        userId: 'user_c',
        userName: 'Emily Watson',
        userPhoto: 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&auto=format&fit=crop',
        rating: 5.0,
        text: 'Ubud was a dream! Loved the rice terraces. Extremely friendly locals and very affordable food.',
        date: DateTime.now().subtract(const Duration(days: 2)),
      ),
    ],
  };

  @override
  Future<List<DestinationModel>> getFeaturedDestinations() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _destinations.where((d) => d.isFeatured).toList();
  }

  @override
  Future<List<DestinationModel>> getDestinationsByCategory(String categoryId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _destinations.where((d) => d.categoryId == categoryId).toList();
  }

  @override
  Future<List<DestinationModel>> searchDestinations(String query) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (query.trim().isEmpty) return _destinations;
    final lowercaseQuery = query.toLowerCase();
    return _destinations.where((d) => 
      d.name.toLowerCase().contains(lowercaseQuery) || 
      d.city.toLowerCase().contains(lowercaseQuery) || 
      d.description.toLowerCase().contains(lowercaseQuery)
    ).toList();
  }

  @override
  Future<List<DestinationModel>> getAllDestinations() async {
    await Future.delayed(const Duration(milliseconds: 800));
    return _destinations;
  }

  @override
  Future<List<ReviewModel>> getDestinationReviews(String destinationId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _reviews[destinationId] ?? [];
  }

  @override
  Future<List<CategoryModel>> getCategories() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _categories;
  }

  @override
  Future<List<BannerModel>> getBanners() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return _banners;
  }

  @override
  Future<List<PackageModel>> getPackages() async {
    await Future.delayed(const Duration(milliseconds: 600));
    return _packages;
  }
}
