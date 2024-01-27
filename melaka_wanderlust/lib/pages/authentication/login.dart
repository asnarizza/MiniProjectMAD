import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:melaka_wanderlust/components/my_button.dart';
import 'package:melaka_wanderlust/components/my_textfield.dart';
import 'package:melaka_wanderlust/pages/authentication/register.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_pw.dart';
import '../home.dart';

class LoginPage extends StatefulWidget {

  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

    // text editing controllers
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool isPasswordVisible = false;

    @override
    void initState() {
      super.initState();
      // Show the pop-up ad when the widget is first created
      Future.delayed(Duration.zero, () {
        showPopupAd();
      });
    }

    // Method to show the pop-up ad
    void showPopupAd() {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Image.asset('lib/images/logo_tmm.png'), // Replace with your image path
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }


    // New method to toggle password visibility
    void togglePassword() {
      setState(() {
        isPasswordVisible = !isPasswordVisible;
      });
    }

    // user login method
    void userLogin() async {
      showLoadingIndicator(true);
      // show loading circle
      showDialog(
          context: context,
          builder: (context) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          },
      );

      try {
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passwordController.text,
        );

        // Check if user is active in Firestore
        DocumentSnapshot userSnapshot =
        await FirebaseFirestore
            .instance
            .collection('users')
            .doc(userCredential.user!.email)
            .get();

        if (userSnapshot.exists) {
          var isActiveData = userSnapshot.data() as Map<String, dynamic>;
          bool isActive = false;

          // Handle both bool and String types for isActive
          if (isActiveData.containsKey('isActive')) {
            var isActiveValue = isActiveData['isActive'];
            if (isActiveValue is bool) {
              isActive = isActiveValue;
            } else if (isActiveValue is String) {
              isActive = isActiveValue.toLowerCase() == 'true';
            }
          }

          if (isActive) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setString('username', emailController.text);
            Navigator.pop(context); // Pop loading circle
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => HomePage()));
          } else {
            showLoadingIndicator(false); // Hide loading indicator
            showErrorMessage("Your account is inactive.");
          }
        } else {
          showLoadingIndicator(false); // Hide loading indicator
          showErrorMessage("Account does not exist.");
        }
      } on FirebaseAuthException catch (e) {
        showLoadingIndicator(false); // Hide loading indicator
        showErrorMessage("Invalid username or password.");
      }
    }
    void showLoadingIndicator(bool show) {
      if (show) {
        showDialog(
          context: context,
          // Prevents closing the dialog by tapping outside of it
          barrierDismissible: false,
          builder: (context) =>
          const Center(
              child: CircularProgressIndicator()),
        );
      } else {
        if (Navigator.canPop(context)) {
          Navigator.pop(context); // Close the loading dialog if it's open
        }
      }
    }

    void showErrorMessage(String message) {
      if (Navigator.canPop(context)) {
        Navigator.pop(context); // Ensure loading circle is closed
      }
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Login Failed'),
            content: Text(message),
            actions: [
              TextButton(
                child: const Text('OK'),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          );
        },
      );
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      // safe area of the screen - guarantee visible to user
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              // allign everything to the middle of the screen
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5),
                //logo
                Image.asset(
                  'lib/images/logo.png',
                    height: 250,
                ),
                const SizedBox(height: 55),

                // text under the lock icon
                Text(
                  'Welcome back you\'ve been missed !',
                  style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                  ),
                ),
                const SizedBox(height: 25),

                // username textfield
                MyTextField(
                  controller: emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),
                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: passwordController,
                  hintText: 'Password',
                  obscureText: !isPasswordVisible, // Update obscureText based on visibility state
                  suffixIcon: IconButton(
                    onPressed: togglePassword,
                    icon: Icon(
                      isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // forgot password
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                              builder: (context) {
                                return ForgotPassPage();
                              },
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 25),

                // log in button
                MyButton(
                  text: "Log In",
                  onTap: userLogin,
                ),

                const SizedBox(height: 50),

                // doesn't have an account
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Doesn\'t have an account?',
                          style: TextStyle(color: Colors.black),
                    ),
                    const SizedBox(width: 4),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              return RegisterPage();
                            },
                          ),
                        );
                      },
                      child: const Text(
                        'Create Account',
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
