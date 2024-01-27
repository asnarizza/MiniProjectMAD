import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:melaka_wanderlust/pages/profile.dart';
import 'package:melaka_wanderlust/pages/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../components/nav_bar.dart';
import '../../models/place.dart';
import '../../models/star_rating.dart';
import '../home.dart';
import '../place_detail.dart';

class HighRatedLocationsPage extends StatefulWidget {

  @override
  _HighRatedLocationsScreenState createState() =>
      _HighRatedLocationsScreenState();
}

class _HighRatedLocationsScreenState extends State<HighRatedLocationsPage> {
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('High Rated Locations'),
        backgroundColor: Colors.orange,
      ),
      body: FutureBuilder(
        future: getHighRatedLocations(),
        builder: (context, AsyncSnapshot<List<Map<String, dynamic>>> snapshot){
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text('No high rated locations found.'),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                var locationData = snapshot.data![index];
                var name = locationData['location'];
                var imagePath = locationData['imagePath'];
                var description = locationData['description'];
                var operatingHours = locationData['operatingHours'];
                var minPrice = locationData['minPrice'];
                var maxPrice = locationData['maxPrice'];
                // add
                var latitude = locationData['latitude'];
                var longitude = locationData['longitude'];

                Place place = Place(
                  name: name,
                  imagePath: imagePath,
                  description: description,
                  operatingHours: operatingHours,
                  minPrice: minPrice,
                  maxPrice: maxPrice,
                  firestoreId: '',
                  type: PlaceType.Restaurant,
                  category: '',
                  website: '',
                  descLink: '',
                  // add
                  latitude: latitude,
                  longitude: longitude,
                );

                return GestureDetector(
                  onTap: () {
                    //Navigate to PlaceDetailPage when a place is tapped
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlaceDetailPage(place: place,),
                      ),
                    );
                  },
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.asset(
                        imagePath,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      locationData['location'],
                      style: TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          'Rating: ',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        StarRating(
                          rating: (locationData['rating'] as double?) ?? 0.0,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 1,
        onTap: (index) async {
          SharedPreferences prefs = await SharedPreferences.getInstance();
          emailController.text = prefs.getString('username')!;
          // Handle navigation based on the index
          switch (index) {
            case 0:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HomePage(),
                ),
              );
              break;
            case 1:
            // currently in high review page
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      WishlistPage(username: emailController.text),
                ),
              );
              break;
            // case 3:
            //   Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(
            //       builder: (context) => PromotionsScreen(),
            //     ),
            //   );
            //   break;
            // case 4:
            //   Navigator.of(context).pushReplacement(
            //     MaterialPageRoute(
            //       builder: (context) => TipsAndAdviceScreen(),
            //     ),
            //   );
            //   break;
            case 3:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(),
                ),
              );
              break;
          }
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getHighRatedLocations() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('reviews')
          .where('rating', isGreaterThanOrEqualTo: 4.0)
          .orderBy('rating', descending: true)
          .get();

      List<Map<String, dynamic>> locations = [];

      for (var doc in querySnapshot.docs) {
        locations.add({
          'location': doc['location'],
          'rating': doc['rating'],
          'imagePath': doc['imagePath'],
          'description': doc['description'],
          'operatingHours': doc['operatingHours'],
          'minPrice': doc['minPrice'],
          'maxPrice': doc['maxPrice'],
          // add
          'latitude': doc['latitude'],
          'longitude': doc['longitude'],
        });
      }

      // Remove duplicates based on 'location'
      List<Map<String, dynamic>> uniqueLocations = [];
      Set<String> uniqueSet = Set();

      for (var location in locations) {
        if (uniqueSet.add(location['location'])) {
          uniqueLocations.add(location);
        }
      }

      return uniqueLocations;
    } catch (e) {
      print('Error fetching high-rated locations: $e');
      return [];
    }
  }
}
