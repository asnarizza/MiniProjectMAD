import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:melaka_wanderlust/pages/authentication/login.dart';
import 'package:melaka_wanderlust/models/wishlist.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  Wishlist wishlist = Wishlist();
  await wishlist.fetchPlaceWishlist();

  runApp(
    ChangeNotifierProvider(
      create: (context) => Wishlist(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    );
  }
}
