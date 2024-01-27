import 'package:flutter/material.dart';

class MyTextField extends StatelessWidget {
  final controller;
  final String hintText;
  final bool obscureText;
  final VoidCallback? onTap;
  final Widget? suffixIcon;

  MyTextField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.obscureText,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: hintText == 'Date of Birth' ?
        TextInputType.datetime : null,
        onTap: onTap,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
          ),
          fillColor: Colors.white,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(color: Colors.grey[500]),
          suffixIcon: suffixIcon,
          prefixIcon
              : hintText == 'Full Name'
              ? Icon(Icons.person, color: Colors.grey[500])
              : hintText == 'Gender'
              ? Icon(Icons.male, color: Colors.grey[500])
              : hintText == 'Date of Birth'
              ? Icon(Icons.cake, color: Colors.grey[500])
              : hintText == 'Phone Number'
              ? Icon(Icons.phone, color: Colors.grey[500])
              : hintText == 'State'
              ? Icon(Icons.location_city, color: Colors.grey[500])
              : hintText == 'Email'
              ? Icon(Icons.email, color: Colors.grey[500])
              : hintText == 'Password'
              ? Icon(Icons.lock, color: Colors.grey[500])
              : hintText == 'Confirm Password'
              ? Icon(Icons.lock, color: Colors.grey[500])
              : null,
        ),
      ),
    );
  }
}
