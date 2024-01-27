import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              Icons.search,
              color: currentIndex == 0 ? Colors.orange : Colors.grey,
            ),
            label: 'Explore',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.location_city,
              color: currentIndex == 1 ? Colors.orange : Colors.grey,
            ),
            label: 'High Rated Locations',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.favorite,
              color: currentIndex == 2 ? Colors.orange : Colors.grey,
            ),
            label: 'Wishlist',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.account_circle,
              color: currentIndex == 3 ? Colors.orange : Colors.grey,
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
