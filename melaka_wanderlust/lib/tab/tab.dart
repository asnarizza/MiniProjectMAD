import 'package:flutter/material.dart';

class MyTab extends StatelessWidget {
  final String iconPath;
  final String name;
  final bool isActive;

  const MyTab({
    super.key,
    required this.iconPath,
    required this.name,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tab(
      child: Container(
        height: 100,
        child: Column(
          children: [
            Flexible(
              child: Image.asset(
                iconPath,
                height: 100,
                //fit: BoxFit.contain,
                color: isActive ? Colors.orange : null,
              ),
            ),
            SizedBox(height: 1),
            Text(
              name,
              style: TextStyle(
                color: isActive ? Colors.orange : Colors.black,
              ), // Set text color to black
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTab {
  final String iconPath;
  final String name;

  CustomTab({required this.iconPath, required this.name});
}