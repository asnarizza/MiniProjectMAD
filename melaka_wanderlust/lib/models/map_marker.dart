import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceInfo {
  final String name;
  final String imagePath;
  final double minPrice;
  final double maxPrice;
  final String briefDesc;
  final LatLng latLng;
  final String type;

  PlaceInfo(
      this.name,
      this.imagePath,
      this.minPrice,
      this.maxPrice,
      this.briefDesc,
      this.latLng,
      this.type,
      );
}

List<PlaceInfo> markersData = [];
