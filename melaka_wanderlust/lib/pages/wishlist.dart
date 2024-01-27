import 'package:flutter/material.dart';
import 'package:melaka_wanderlust/pages/profile.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/nav_bar.dart';
import '../components/wishlist_item.dart';
import '../models/wishlist.dart';
import 'review/high_reviews.dart';
import 'home.dart';
import 'itinerary.dart';

class WishlistPage extends StatelessWidget {

  final String username; // Provide the username

  WishlistPage({Key? key, required this.username});

  void _showGenerateItineraryDialog(BuildContext context) {
    showDialog(
      context: context,
      // Prevent dismissing the dialog by tapping outside
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, setState) {
            return AlertDialog(
              title: Text('Generating Itinerary'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 16),
                  Text(
                    'We are generating the optimal itinerary for your '
                        'trip based on your current location.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'The visit order is determined to save you time '
                        'and enhance your experience.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 12),
                  Text(
                    'You can drag and reorder the list according to '
                        'your preferences once the itinerary is ready.',
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        // Close the dialog when the itinerary is ready
                        Navigator.of(context).pop();

                        // Navigate to the ItineraryPage
                        SharedPreferences prefs =
                        await SharedPreferences.getInstance();
                        String? username = prefs.getString("username");
                        final wishlistItem = await Provider.of<Wishlist>(
                            context, listen: false).getUserWishlist(username!);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ItineraryPage(wishlistItems: wishlistItem),
                          ),
                        );
                      },
                      child: Text(
                        'OK',
                        style: TextStyle(
                            fontSize: 18,
                            color: Colors.orange),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("My Wishlist"),
      ),
      body: Consumer<Wishlist>(
        builder: (context, wishlist, child) {
          return FutureBuilder<List<Map<String, dynamic>>>(
            future: wishlist.getUserWishlist(username),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                // Show a loading indicator while waiting for data
                return Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                // Handle errors if any
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                // Handle the case when there's no data to display
                return Center(child: Text('No items in the wishlist.'));
              } else {
                // Process and display the data
                final wishlistPlaces = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Expanded(
                        child: ListView.builder(
                          itemCount: wishlistPlaces.length,
                          itemBuilder: (context, index) {
                            Map<String, dynamic> wishlistItem =
                            wishlistPlaces[index];
                            return WishlistItem(wishlistItem: wishlistItem);
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
      bottomNavigationBar: Column(
        // Wrap the two bottom navigation components in a Column
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: ElevatedButton(
              child: Text(
                'Generate Itinerary',
                style: TextStyle(fontSize: 18),
              ),
              onPressed: () async {
                SharedPreferences prefs =
                await SharedPreferences.getInstance();
                String? username = prefs.getString("username");
                final wishlistItem = await Provider.of<Wishlist>(context,
                    listen: false)
                    .getUserWishlist(username!);

                _showGenerateItineraryDialog(context);

                Future.delayed(Duration(seconds: 7), (){
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ItineraryPage(wishlistItems: wishlistItem)
                    ),
                  );
                }
                );
              },
              style: ElevatedButton.styleFrom(
                primary: Colors.orange,
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
          CustomBottomNavigationBar(
            currentIndex: 2,
            onTap: (index) {
              switch (index) {
                case 0:
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HomePage(),
                    ),
                  );
                  break;
                case 1:
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => HighRatedLocationsPage(),
                    ),
                  );
                  break;
                case 2:
                  // currently in wishlist page
                  break;
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
        ],
      ),
    );
  }
}