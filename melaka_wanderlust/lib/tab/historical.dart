import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:melaka_wanderlust/models/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/map_marker.dart';
import '../models/place.dart';
import '../components/place_tile.dart';

class HistoricalTab extends StatelessWidget {

  final CustomInfoWindowController customInfoWindowController;
  double? rating;

  HistoricalTab({
    Key? key,
    required this.customInfoWindowController}) : super(key: key);

  void addHistoricalToWishlist(BuildContext context, Historical historical) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    Provider.of<Wishlist>(context, listen: false).addPlaceToUserWishlist(username!,historical);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Successfully added!'),
        content: Text('Check your wishlist'),
      ),
    );
  }

  // markers
  Future<List<PlaceInfo>> fetchData(String type) async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(type).get();
      return querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Print the data for debugging
        print('Data for document ${doc.id}: $data');

        return PlaceInfo(
          data['name'] ?? '',
          data['imagePath'] ?? '',
          (data['minPrice'] as num?)?.toDouble() ?? 0.0,
          (data['maxPrice'] as num?)?.toDouble() ?? 0.0,
          data['briefDesc'] ?? '',
          LatLng(
            (data['latitude'] as num?)?.toDouble() ?? 0.0,
            (data['longitude'] as num?)?.toDouble() ?? 0.0,
          ),
          type,
        );
      }).toList();
    } catch (error) {
      print('Error fetching data: $error');
      return [];
    }
  }

  Future<void> fetchRating(String placeName) async {
    try {
      QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('location', isEqualTo: placeName)
          .get();

      if (reviewsSnapshot.docs.isNotEmpty) {
        double totalRating = 0.0;
        for (var reviewDoc in reviewsSnapshot.docs) {
          totalRating += (reviewDoc['rating'] as double?) ?? 0.0;
        }
        rating = totalRating / reviewsSnapshot.docs.length;
      }

      // return null; // Return null if no reviews available
    } catch (error) {
      print('Error fetching rating: $error');
      // return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.only(top: 12),
            child: Stack(
              children: [
                FutureBuilder<List<PlaceInfo>>(
                  future: fetchData('historicals'), // Fetch data for 'beaches' collection
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text('No data available.');
                    } else {
                      List<PlaceInfo> beachList = snapshot.data!;
                      return GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: LatLng(2.18781, 102.25476),
                          zoom: 15,
                        ),
                        markers: Set<Marker>.of(
                          beachList.map((placeInfo) {
                            return Marker(
                              markerId: MarkerId('${placeInfo.type}_${placeInfo.name}'),
                              icon: BitmapDescriptor.defaultMarker,
                              position: placeInfo.latLng,
                              onTap: () async {
                                await fetchRating(placeInfo.name);
                                customInfoWindowController.addInfoWindow!(
                                  Container(
                                    height: 700,
                                    width: 300,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(10.0),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 300,
                                          height: 130,
                                          decoration: BoxDecoration(
                                            image: DecorationImage(
                                              image: AssetImage(placeInfo.imagePath),
                                              fit: BoxFit.fitWidth,
                                              filterQuality: FilterQuality.high,
                                            ),
                                            borderRadius: BorderRadius.circular(5.0),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  placeInfo.name,
                                                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                                ),
                                                SizedBox(height: 5),
                                                if (rating != null)
                                                  Row(
                                                    children: [
                                                      RatingBarIndicator(
                                                        rating: rating!,
                                                        itemBuilder: (context, index) =>
                                                            Icon(Icons.star, color: Colors.amber),
                                                        itemCount: 5,
                                                        itemSize: 18.0,
                                                        direction: Axis.horizontal,
                                                      ),
                                                    ],
                                                  ),
                                                if (rating == null)
                                                  Padding(
                                                    padding: const EdgeInsets.only(top: 4.0),
                                                    child: Text('No reviews available'),
                                                  ),
                                                SizedBox(height: 5),
                                                Text(
                                                  placeInfo.minPrice == 0
                                                      ? 'Free Entry'
                                                      : 'Price: RM ${placeInfo.minPrice} - RM ${placeInfo.maxPrice}',
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    color: Colors.green, // Set the text color to green
                                                  ),
                                                ),
                                                SizedBox(height: 5),
                                                Text(
                                                  '${placeInfo.briefDesc}', // Add category here
                                                  style: TextStyle(fontSize: 14),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  placeInfo.latLng,
                                );
                              },
                            );
                          }),
                        ),
                        onTap: (position) {
                          customInfoWindowController.hideInfoWindow!();
                        },
                        onCameraMove: (position) {
                          customInfoWindowController.onCameraMove!();
                        },
                        onMapCreated: (GoogleMapController controller) {
                          customInfoWindowController.googleMapController = controller;
                        },
                      );
                    }
                  },
                ),
                CustomInfoWindow(
                  controller: customInfoWindowController,
                  height: 300,
                  width: 300,
                  offset: 35,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: Consumer<Wishlist>(
            builder: (context, value, child) {
              return FutureBuilder<List<Historical>>(
                future: value.fetchHistoricalList(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('No data available.');
                  } else {
                    List<Historical> historicalList = snapshot.data!;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 12),
                          Expanded(
                            child: ListView.builder(
                              itemCount: historicalList.length,
                              itemBuilder: (context, index) {
                                Historical historical = historicalList[index];
                                // Determine whether the beach is a favorite or not
                                bool isFavorite = value.isPlaceInWishlist(historical);
                                return PlaceTile(place: historical, isFavorite: isFavorite);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
