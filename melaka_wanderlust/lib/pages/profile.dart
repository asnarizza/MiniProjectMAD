import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:melaka_wanderlust/pages/review/high_reviews.dart';
import 'package:melaka_wanderlust/pages/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import '../components/nav_bar.dart';
import 'authentication/forgot_pw.dart';
import 'home.dart';
import 'authentication/login.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String profilePictureURL = '';
  String membershipType = '';
  String selectedGender = 'Male';
  String selectedState = 'Johor';

  Key profilePictureKey = UniqueKey();

  // A map to keep track of the edit states for each field
  final Map<String, bool> editStates = {
    'full name': false,
    'gender': false,
    'state': false,
    'date of birth': false,
    'phone number': false,
    'email': false,
  };

  final List<String> genderOptions = ['Male', 'Female'];

  final List<String> stateOptions = [
    'Johor',
    'Kedah',
    'Kelantan',
    'Kuala Lumpur',
    'Labuan',
    'Melaka',
    'Negeri Sembilan',
    'Pahang',
    'Penang',
    'Perak',
    'Perlis',
    'Putrajaya',
    'Sabah',
    'Sarawak',
    'Selangor',
    'Terengganu',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    // Fetch user data from Firestore and populate the text controllers
    fetchDataFromFirestore();
  }

  Future<void> fetchDataFromFirestore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email =
    prefs.getString('username');

    if (email != null) {
      try {
        DocumentSnapshot userSnapshot =
        await FirebaseFirestore.instance.collection('users').doc(email).get();

        if (userSnapshot.exists) {
          var userData = userSnapshot.data() as Map<String, dynamic>;

          setState(() {
            fullNameController.text = userData['full name'] ?? '';
            selectedGender = userData['gender'] ?? '';
            selectedState = userData['state'] ?? '';
            dateOfBirthController.text =
                userData['date of birth']?.toString() ?? '';
            phoneNumberController.text =
                userData['phone number']?.toString() ?? '';
            emailController.text = email;
            passwordController.text = userData['password'] ?? '';

            // Set the profile picture URL if available
            profilePictureURL = userData['profilePicture'] ?? '';

            membershipType = userData['membershipType'] ?? '';
          });
        } else {
          print("User data does not exist");
        }
      } catch (error) {
        print("Firestore Error: $error");
      }
    } else {
      print("Email is null in SharedPreferences");
    }
  }

  Future<void> uploadProfilePicture(String userEmail, XFile pickedImage) async {
    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child('$userEmail.jpg');

      final UploadTask uploadTask = storageReference.putFile(
          File(pickedImage.path));
      final TaskSnapshot taskSnapshot = await uploadTask;

      if (taskSnapshot.state == TaskState.success) {
        final String downloadURL = await storageReference.getDownloadURL();

        // Update Firestore with the downloadURL
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userEmail)
            .update({
          'profilePicture': downloadURL,
        });

        // Update the profile picture URL in the state
        setState(() {
          profilePictureURL = downloadURL;
          profilePictureKey = UniqueKey();
        });
      }
    } catch (error) {
      print("Image Upload Error: $error");
    }
  }

  void updateUserDetails() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username =
    prefs.getString('username');

    if (username != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(username)
          .update({
          'full name': fullNameController.text,
          'gender': selectedGender,
          'state': selectedState,
          'date of birth': dateOfBirthController.text,
          'phone number': int.parse(phoneNumberController.text),
          'email': emailController.text,
        },
      );
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Profile Updated'),
            content: Text('Your profile has been successfully updated.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Widget buildEditableTextBox({
    required TextEditingController controller,
    required String labelText,
    required Function() onEditPressed,
    required bool isEditable,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              controller: controller,
              readOnly: !isEditable,
              decoration: InputDecoration(
                labelText: labelText,
                labelStyle: TextStyle(
                  color: isEditable ? Colors.orange : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit,
              color: Colors.orange,
            ),
            onPressed: onEditPressed,
          ),
        ],
      ),
    );
  }

  // Function to log out the user
  void _logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Show a confirmation dialog before logging out
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                await prefs.clear();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  // Function to delete the user account
  void _deleteAccount(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('username');

    if (email != null && email.isNotEmpty) {
      // Show a confirmation dialog before deleting the account
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirm Delete Account'),
            content: Text('Are you sure you want to delete your account?'
                ' This action cannot be undone.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  try {
                    DocumentReference userDoc = FirebaseFirestore
                        .instance
                        .collection('users')
                        .doc(email);

                    // Check if the user document exists
                    DocumentSnapshot userSnapshot = await userDoc.get();
                    if (userSnapshot.exists) {
                      await userDoc.update({'isActive': false});

                      // Log out the user and navigate to the login screen
                      await prefs.clear();
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                      );
                    } else {
                      print("User account not found.");
                    }
                  } catch (error) {
                    print("An error occurred: ${error.toString()}");
                  }
                },
                child: Text('Delete Account'),
              ),
            ],
          );
        },
      );
    } else {
      print("User not found.");
    }
  }

  // Function to show the bottom sheet with logout and delete account options
  void _showBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.logout),
                title: Text('Logout'),
                onTap: () {
                  Navigator.pop(context);
                  _logout(context);
                },
              ),
              ListTile(
                leading: Icon(Icons.delete),
                title: Text('Delete Account'),
                onTap: () {
                  Navigator.pop(context);
                  _deleteAccount(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              _showBottomSheet(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 20),
              Stack(
                children: [
                  CircleAvatar(
                    radius: 100,
                    key: profilePictureKey,
                    backgroundImage:
                    NetworkImage(profilePictureURL),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      padding: EdgeInsets.all(8.0),
                      child: IconButton(
                        onPressed: () async {
                          final imagePicker = ImagePicker();
                          final pickedImage =
                          await imagePicker.pickImage(
                              source: ImageSource.gallery);

                          if (pickedImage != null) {
                            await uploadProfilePicture(
                                emailController.text,
                                pickedImage);
                          }
                        },
                        icon: Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),
              Card(
                color: Colors.orange,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    'Membership Type: $membershipType',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),
              buildEditableTextBox(
                controller: fullNameController,
                labelText: 'Full Name',
                onEditPressed: () {
                  setState(() {
                    editStates['full name'] = !editStates['full name']!;
                  });
                },
                isEditable: editStates['full name']!,
              ),
              buildGenderDropdown(),
              buildStateDropdown(),
              Container(
                margin: EdgeInsets.symmetric(vertical: 8.0),
                padding: EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  color: Colors.grey[200],
                ),
                child: TextFormField(
                  controller: dateOfBirthController,
                  readOnly: true,
                  onTap: () {
                    _selectDate(context);
                  },
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              buildEditableTextBox(
                controller: phoneNumberController,
                labelText: 'Phone Number',
                onEditPressed: () {
                  setState(() {
                    editStates['phone number'] = !editStates['phone number']!;
                  });
                },
                isEditable: editStates['phone number']!,
              ),
              buildEditableTextBox(
                controller: emailController,
                labelText: 'Email',
                onEditPressed: () {
                  setState(() {
                    editStates['email'] = !editStates['email']!;
                  });
                },
                isEditable: editStates['email']!,
              ),
              buildEditableTextBox(
                controller: passwordController,
                labelText: 'Password',
                onEditPressed: () {
                  // Navigate to the ForgotPassPage
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => ForgotPassPage(),
                    ),
                  );
                },
                isEditable: false,
              ),
              SizedBox(height: 95),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: updateUserDetails,
                  style: ElevatedButton.styleFrom(
                    primary: Colors.orange,
                  ),
                  child: Text(
                    'Update Profile',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: 3,
        onTap: (index) {
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
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => HighRatedLocationsPage(),
                ),
              );
              break;
            case 2:
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) =>
                      WishlistPage(username: emailController.text),
                ),
              );
              break;
            case 3:
              // currently in profile page
              break;
          }
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null && picked != dateOfBirthController.text) {
      setState(() {
        dateOfBirthController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  // gender method
  Widget buildGenderDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gender',
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedGender,
            onChanged: (newValue) {
              setState(() {
                selectedGender = newValue!;
              });
            },
            items: genderOptions.map<DropdownMenuItem<String>>((String gender) {
              return DropdownMenuItem<String>(
                value: gender,
                child: Text(gender),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // state method
  Widget buildStateDropdown() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10.0),
        color: Colors.grey[200],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'State', // Add your label text here
            style: TextStyle(
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          DropdownButtonFormField<String>(
            value: selectedState, // Set the initial value
            onChanged: (newValue) {
              setState(() {
                selectedState = newValue!;
              });
            },
            items: stateOptions.map<DropdownMenuItem<String>>((String state) {
              return DropdownMenuItem<String>(
                value: state,
                child: Text(state),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

}
