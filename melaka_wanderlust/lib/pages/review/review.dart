import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:melaka_wanderlust/pages/review/review_list.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/place.dart';
import '../../models/review.dart';


class ReviewScreen extends StatefulWidget {

  final Place place;

  ReviewScreen({Key? key, required this.place}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  String? username = '';
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      username = prefs.getString("username")!;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Review'),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16),
                  Text('Rating:',
                    style: TextStyle(
                      color: Colors.black, // Change the text color
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  RatingBar.builder(
                    initialRating: _selectedRating,
                    minRating: 1,
                    direction: Axis.horizontal,
                    allowHalfRating: true,
                    itemCount: 5,
                    itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                    itemBuilder: (context, _) => Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    onRatingUpdate: (rating) {
                      setState(() {
                        _selectedRating = rating;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _commentController,
                    decoration: InputDecoration(
                      labelText: 'Comment',
                      filled: true,
                      fillColor: Colors.grey[200],),
                  ),
                  SizedBox(height: 1000), // Space for the button
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                child: Text(
                  'Submit',
                  style: TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  submitReview();
                },
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange,
                  minimumSize: Size(double.infinity, 50),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> submitReview() async {
    if (_selectedRating == 0.0) {
      // Show an error message or handle the case where no rating is selected
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select a rating"),
        ),
      );
      return;
    }

    // Create a Review object with the entered data
    Review newReview = Review(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      username: username!,
      location: widget.place.name,
      rating: _selectedRating,
      comment: _commentController.text,
      date: DateTime.now(),
      imagePath: widget.place.imagePath,
    );

    try {
      // Store the review in Firestore
      await FirebaseFirestore.instance.collection('reviews').add({
        'username': newReview.username,
        'location': newReview.location,
        'imagePath': newReview.imagePath,
        'description': widget.place.description,
        'operatingHours': widget.place.operatingHours,
        'minPrice': widget.place.minPrice,
        'maxPrice': widget.place.maxPrice,
        // add
        'latitude': widget.place.latitude,
        'longitude': widget.place.longitude,
        'rating': newReview.rating, // Store the rating as a double
        'comment': newReview.comment,
        'date': newReview.date,
      });

      // Show success AlertDialog
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Review Submitted'),
            content: Text('Your review has been successfully submitted.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) =>
                        ReviewListScreen(
                            place: widget.place
                        )
                    ),
                  );
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      // Handle any errors that may occur when storing the review in Firestore
      print('Error submitting review: $e');
      // You can show an error message to the user if needed
    }
  }
}

