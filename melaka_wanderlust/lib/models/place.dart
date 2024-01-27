import 'package:cloud_firestore/cloud_firestore.dart';

enum PlaceType { Beach, Historical, Attraction, Restaurant }

class Place {
  final String firestoreId;
  final String name;
  final String description;
  final double minPrice;
  final double maxPrice;
  final String imagePath;
  final PlaceType type;
  final String category;
  final String operatingHours;
  final String website;
  final String descLink;
  final double latitude;
  final double longitude;

  Place({
    required this.firestoreId,
    required this.name,
    required this.description,
    required this.minPrice,
    required this.maxPrice,
    required this.imagePath,
    required this.type,
    required this.category,
    required this.operatingHours,
    required this.website,
    required this.descLink,
    required this.latitude,
    required this.longitude,
  });




  // Define a static method to load all places from Firestore
  static Future<List<Place>> loadAll({required String collection}) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot =
      await FirebaseFirestore.instance.collection('places').get();
      return querySnapshot.docs.map((doc) {
        return Place.fromFirestore(doc);
      }).toList();
    } catch (error) {
      print('Error loading places: $error');
      return [];
    }
  }

  // Named constructor to create a Place instance from a Firestore document
  factory Place.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Place(
      firestoreId: document.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
      imagePath: (data['imagePath'] as String?) ?? '',
      type: _parsePlaceType((data['type'] as String?) ?? ''),
      category: (data['category'] as String?) ?? '',
      operatingHours: (data['operatingHours'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      descLink: (data['descLink'] as String?) ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }

  static PlaceType _parsePlaceType(String type) {
    switch (type) {
      case 'beach':
        return PlaceType.Beach;
      case 'historical':
        return PlaceType.Historical;
      case 'attraction':
        return PlaceType.Attraction;
      case 'restaurant':
        return PlaceType.Restaurant;
      default:
        throw ArgumentError('Invalid PlaceType: $type');
    }
  }
}

class Beach extends Place {
  Beach({
    required String firestoreId,
    required String name,
    required String description,
    required double minPrice,
    required double maxPrice,
    required String imagePath,
    required String category,
    required String operatingHours,
    required String website,
    required String descLink,
    required double latitude,
    required double longitude,
  }) : super(
    firestoreId: firestoreId,
    name: name,
    description: description,
    minPrice: minPrice,
    maxPrice: maxPrice,
    imagePath: imagePath,
    type: PlaceType.Beach,
    category: category,
    operatingHours: operatingHours,
    website: website,
    descLink: descLink,
    latitude: latitude,
    longitude: longitude,
  );

  factory Beach.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Beach(
      firestoreId: document.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
      imagePath: (data['imagePath'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      operatingHours: (data['operatingHours'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      descLink: (data['descLink'] as String?) ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Historical extends Place {
  Historical({
    required String firestoreId,
    required String name,
    required String description,
    required double minPrice,
    required double maxPrice,
    required String imagePath,
    required String category,
    required String operatingHours,
    required String website,
    required String descLink,
    required double latitude,
    required double longitude,
  }) : super(
    firestoreId: firestoreId,
    name: name,
    description: description,
    minPrice: minPrice,
    maxPrice: maxPrice,
    imagePath: imagePath,
    type: PlaceType.Historical,
    category: category,
    operatingHours: operatingHours,
    website: website,
    descLink: descLink,
    latitude: latitude,
    longitude: longitude,
  );

  factory Historical.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Historical(
      firestoreId: document.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
      imagePath: (data['imagePath'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      operatingHours: (data['operatingHours'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      descLink: (data['descLink'] as String?) ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Attraction extends Place {
  Attraction({
    required String firestoreId,
    required String name,
    required String description,
    required double minPrice,
    required double maxPrice,
    required String imagePath,
    required String category,
    required String operatingHours,
    required String website,
    required String descLink,
    required double latitude,
    required double longitude,
  }) : super(
    firestoreId: firestoreId,
    name: name,
    description: description,
    minPrice: minPrice,
    maxPrice: maxPrice,
    imagePath: imagePath,
    type: PlaceType.Attraction,
    category: category,
    operatingHours: operatingHours,
    website: website,
    descLink: descLink,
    latitude: latitude,
    longitude: longitude,
  );

  factory Attraction.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Attraction(
      firestoreId: document.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
      imagePath: (data['imagePath'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      operatingHours: (data['operatingHours'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      descLink: (data['descLink'] as String?) ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class Restaurant extends Place {
  Restaurant({
    required String firestoreId,
    required String name,
    required String description,
    required double minPrice,
    required double maxPrice,
    required String imagePath,
    required String category,
    required String operatingHours,
    required String website,
    required String descLink,
    required double latitude,
    required double longitude,
  }) : super(
    firestoreId: firestoreId,
    name: name,
    description: description,
    minPrice: minPrice,
    maxPrice: maxPrice,
    imagePath: imagePath,
    type: PlaceType.Restaurant,
    category: category,
    operatingHours: operatingHours,
    website: website,
    descLink: descLink,
    latitude: latitude,
    longitude: longitude,
  );

  factory Restaurant.fromFirestore(
      QueryDocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();
    return Restaurant(
      firestoreId: document.id,
      name: (data['name'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      minPrice: (data['minPrice'] as num?)?.toDouble() ?? 0.0,
      maxPrice: (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
      imagePath: (data['imagePath'] as String?) ?? '',
      category: (data['category'] as String?) ?? '',
      operatingHours: (data['operatingHours'] as String?) ?? '',
      website: (data['website'] as String?) ?? '',
      descLink: (data['descLink'] as String?) ?? '',
      latitude: (data['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (data['longitude'] as num?)?.toDouble() ?? 0.0,
    );
  }
}