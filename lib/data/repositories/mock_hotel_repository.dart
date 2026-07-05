import '../../core/constants/app_assets.dart';
import '../../domain/repositories/hotel_repository.dart';
import '../models/hotel_model.dart';

class MockHotelRepository implements HotelRepository {
  final List<HotelModel> _hotels = [
    HotelModel(
      id: 'hot_ritz_paris',
      name: 'Ritz Paris',
      destinationId: 'dest_paris',
      images: [
        AppAssets.hotelRitzParis,
        'https://images.unsplash.com/photo-1542314831-068cd1dbfeeb?w=800&auto=format&fit=crop',
      ],
      pricePerNight: 850.0,
      rating: 4.9,
      amenities: ['Free WiFi', 'Swimming Pool', 'Spa & Wellness', 'Michelin Restaurant', 'Bar', 'Gym'],
      distanceFromCenter: '0.2 km from Center',
      latitude: 48.8681,
      longitude: 2.3294,
      isAvailable: true,
    ),
    HotelModel(
      id: 'hot_pulitzer_paris',
      name: 'Hotel Pulitzer Paris',
      destinationId: 'dest_paris',
      images: [
        'https://images.unsplash.com/photo-1551882547-ff40c63fe5fa?w=800&auto=format&fit=crop',
      ],
      pricePerNight: 240.0,
      rating: 4.5,
      amenities: ['Free WiFi', 'Bar', 'Air Conditioning', 'Room Service'],
      distanceFromCenter: '1.5 km from Center',
      latitude: 48.8732,
      longitude: 2.3435,
      isAvailable: true,
    ),
    HotelModel(
      id: 'hot_fourseasons_bali',
      name: 'Four Seasons Resort Bali',
      destinationId: 'dest_bali',
      images: [
        AppAssets.hotelFourSeasonsBali,
        'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=800&auto=format&fit=crop',
      ],
      pricePerNight: 620.0,
      rating: 4.8,
      amenities: ['Infinity Pool', 'Beach Access', 'Spa', 'Yoga Classes', 'Free WiFi', 'Kids Club'],
      distanceFromCenter: '2.1 km from Center',
      latitude: -8.7042,
      longitude: 115.1764,
      isAvailable: true,
    ),
    HotelModel(
      id: 'hot_ubud_hanging',
      name: 'Ubud Hanging Gardens',
      destinationId: 'dest_bali',
      images: [
        'https://images.unsplash.com/photo-1584132967334-10e028bd69f7?w=800&auto=format&fit=crop',
      ],
      pricePerNight: 410.0,
      rating: 4.7,
      amenities: ['Twin Pools', 'Jungle View', 'Spa', 'Restaurant', 'Free Shuttle'],
      distanceFromCenter: '4.8 km from Ubud Center',
      latitude: -8.4124,
      longitude: 115.2798,
      isAvailable: true,
    ),
    HotelModel(
      id: 'hot_kyoto_ryokan',
      name: 'Gion Hatanaka Ryokan',
      destinationId: 'dest_kyoto',
      images: [
        AppAssets.hotelKyotoRyokan,
        'https://images.unsplash.com/photo-1503899036084-c55cdd92da26?w=800&auto=format&fit=crop',
      ],
      pricePerNight: 350.0,
      rating: 4.9,
      amenities: ['Tatami Rooms', 'Onsen Hot Spring', 'Traditional Kaiseki dinner', 'Free WiFi', 'Garden View'],
      distanceFromCenter: '0.5 km from Gion',
      latitude: 35.0028,
      longitude: 135.7785,
      isAvailable: true,
    ),
    HotelModel(
      id: 'hot_rome_palace',
      name: 'Singer Palace Hotel Rome',
      destinationId: 'dest_rome',
      images: [
        AppAssets.hotelRomePalace,
        'https://images.unsplash.com/photo-1618773928121-c32242e63f39?w=800&auto=format&fit=crop',
      ],
      pricePerNight: 480.0,
      rating: 4.8,
      amenities: ['Rooftop Terrace', 'Free WiFi', 'Bar', 'Airport Shuttle', 'Soundproof Rooms'],
      distanceFromCenter: '0.1 km from Trevi Fountain',
      latitude: 41.9001,
      longitude: 12.4812,
      isAvailable: true,
    ),
  ];

  @override
  Future<List<HotelModel>> getHotelsForDestination(String destinationId) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _hotels.where((h) => h.destinationId == destinationId).toList();
  }

  @override
  Future<List<HotelModel>> getAllHotels() async {
    await Future.delayed(const Duration(milliseconds: 700));
    return _hotels;
  }

  @override
  Future<HotelModel?> getHotelDetails(String hotelId) async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      return _hotels.firstWhere((h) => h.id == hotelId);
    } catch (_) {
      return null;
    }
  }
}
