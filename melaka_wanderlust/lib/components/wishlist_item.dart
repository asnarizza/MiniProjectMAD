import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/wishlist.dart';

class WishlistItem extends StatelessWidget {

  Map<String, dynamic> wishlistItem;

  WishlistItem({
    Key? key,
    required this.wishlistItem
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<Wishlist>(
      builder: (context, wishlist, child) {
        return Material(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            margin: const EdgeInsets.only(top: 8),
            child: ListTile(
              // display place's picture
              leading: Image.asset(
                wishlistItem['imagePath'],
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
              // display place's name
              title: Text(wishlistItem['placeName'].toString()),
              // delete wishlist
              trailing: IconButton(
                onPressed: () async {
                  SharedPreferences prefs =
                  await SharedPreferences.getInstance();
                  String? username = prefs.getString('username');
                  wishlist.removePlaceFromUserWishlist(username!,
                      wishlistItem['placeName'].toString());
                },
                icon: Icon(Icons.delete),
              ),
            ),
          ),
        );
      },
    );
  }
}

