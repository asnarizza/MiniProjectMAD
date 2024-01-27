import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:intl/intl.dart';
import 'package:melaka_wanderlust/pages/review/review.dart';
import '../../models/place.dart';

class ReviewListScreen extends StatelessWidget {
  final Place place;

  ReviewListScreen({
    Key? key,
    required this.place
  }) :super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Reviews'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('location', isEqualTo: place.name)
                  .snapshots(),
              builder: (context, snapshot) {
                print(snapshot);
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(
                    child: Text('No reviews available.'),
                  );
                }

                var reviews = snapshot.data!.docs;
                List<Widget> reviewWidgets = [];

                for (var review in reviews) {
                  var data = review.data() as Map<String, dynamic>;
                  var rating = data['rating'] as double?;

                  if (rating != null) {
                    var timestamp = (data['date'] as Timestamp).toDate();
                    var formattedDate = DateFormat.yMd().format(timestamp);
                    var username = data['username'] as String;
                    var censoredUsername =
                    username.replaceRange(1, username.indexOf('@'), '******');
                    var reviewWidget = ListTile(
                      title: Text(
                          '$censoredUsername',
                        style: TextStyle(
                            fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          RatingBarIndicator(
                            rating: rating,
                            itemBuilder: (context, index) => Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            itemCount: 5,
                            itemSize: 20.0,
                            direction: Axis.horizontal,
                          ),
                          const SizedBox(height: 5),
                          Text(
                              'Comment: ${data['comment']}',
                            style: TextStyle(
                              fontSize: 16,
                            ),
                          ),
                          Text('$formattedDate'),
                        ],
                      ),
                    );
                    reviewWidgets.add(reviewWidget);
                    reviewWidgets.add(Divider(
                        height: 30, color: Colors.grey)
                    );
                  }
                }
                return ListView(
                  children: reviewWidgets,
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16), // Adjust the padding as needed
        child: ElevatedButton.icon(
          icon: Icon(Icons.add), // '+' icon
          label: Text(
            'Add',
            style: TextStyle(fontSize: 18),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>
                  ReviewScreen(place: place)),
            );
          },
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            minimumSize: Size(double.infinity, 50), // Set the button size
          ),
        ),
      ),
    );
  }
}