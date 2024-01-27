import 'package:flutter/material.dart';
import 'package:custom_info_window/custom_info_window.dart';
import 'package:melaka_wanderlust/pages/profile.dart';
import 'package:melaka_wanderlust/pages/search.dart';
import 'package:melaka_wanderlust/pages/wishlist.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../components/nav_bar.dart';
import '../tab/beach.dart';
import '../tab/historical.dart';
import '../tab/hotel.dart';
import '../tab/attraction.dart';
import '../tab/restaurant.dart';
import '../tab/tab.dart';
import 'filter.dart';
import 'review/high_reviews.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final CustomInfoWindowController customInfoWindowController =
  CustomInfoWindowController();
  final TextEditingController searchController = TextEditingController();
  late TabController _tabController;
  bool _isControllerInitialized = false;

  // navigate to user profile page
  void handleProfilePage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfilePage(),
      ),
    );
  }

  // navigate to wishlist page
  void handleWishlist() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WishlistPage(
          username: username!,
        ),
      ),
    );
  }

  void handleHighRatedLocationsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HighRatedLocationsPage(),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: myTabs.length, vsync: this);
    // Add a listener to rebuild the widget when the tab changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        // This triggers a rebuild of the widget so
        // that the active tab color can change
        setState(() {
        });
      }
    });
    _isControllerInitialized = true;
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      // This rebuilds the widget with the updated tab index
      setState(() {});
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  // my tabs
  List<CustomTab> myTabs = [
    CustomTab(iconPath: 'lib/icons/beach.png', name: 'Beaches'),
    CustomTab(iconPath: 'lib/icons/historical.png', name: 'Historicals'),
    CustomTab(iconPath: 'lib/icons/attraction.png', name: 'Attractions'),
    CustomTab(iconPath: 'lib/icons/restaurant.png', name: 'Restaurants'),
    CustomTab(iconPath: 'lib/icons/hotel.png', name: 'Hotels'),
  ];

  @override
  Widget build(BuildContext context) {
    if (!_isControllerInitialized) {
      // Check if the controller is initialized
      return Container();
    }

    return Scaffold(
      appBar: null,
      body: Column(
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchPage(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 1),
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Icon(Icons.search),
                        ),
                        Text(
                          "Where to?",
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.filter_list),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          TabBar(
            controller: _tabController,
            indicatorColor: Colors.orange,
            tabs: List.generate(myTabs.length, (index) {
              return MyTab(
                iconPath: myTabs[index].iconPath,
                name: myTabs[index].name,
                isActive: _tabController.index == index,
              );
            }),
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                BeachTab(
                    customInfoWindowController: customInfoWindowController),
                HistoricalTab(
                    customInfoWindowController: customInfoWindowController),
                AttractionTab(
                    customInfoWindowController: customInfoWindowController),
                RestaurantTab(
                    customInfoWindowController: customInfoWindowController),
                HotelTab(),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _tabController.index.clamp(0, 4),
        onTap: (index) {
          // Handle navigation based on the index
          switch (index) {
            case 0:
            // You're already on the HomePage, no need to navigate
              break;
            case 1:
              handleHighRatedLocationsPage();
              break;
            case 2:
              handleWishlist();
              break;
            case 3:
              handleProfilePage();
              break;
          }
        },
      ),
    );
  }
}
