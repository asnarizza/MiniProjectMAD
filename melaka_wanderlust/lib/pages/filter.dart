import 'package:flutter/material.dart';
import 'package:melaka_wanderlust/models/place.dart';
import 'package:melaka_wanderlust/models/wishlist.dart';
import 'package:melaka_wanderlust/pages/place_detail.dart';

class FilterScreen extends StatefulWidget {

  const FilterScreen({Key? key}) : super(key: key);

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {

  double minBudget = 0.0;
  double maxBudget = 100.0;

  List<String> categories = [
    'Beaches', 'Halal Food', 'Non-Halal Food',
    'Tourist Attractions', 'Zoos & Wildlife',
    'Water Theme Parks', 'Museums & Exhibitions',
    'Religious Places', 'Recreational Activities'
  ];
  Map<String, bool> selectedCategories = {};

  @override
  void initState() {
    super.initState();
    for (var category in categories) {
      selectedCategories[category] = false;
    }
  }

  void _onCategoryChanged(String category, bool isSelected) {
    setState(() {
      selectedCategories[category] = isSelected;
    });
  }

  void _onSubmit() async {
    List<String> selectedCategoryNames =
    selectedCategories.entries.where((entry) =>
    entry.value).map((entry) => entry.key).toList();

    if (selectedCategoryNames.isNotEmpty) {
      Wishlist wishlist = Wishlist();
      List<Place> filteredPlaces = await wishlist.filterPlacesByBudget(
          minBudget,
          maxBudget,
          selectedCategoryNames);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FilteredPlacesScreen(filteredPlaces),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filter'),
        backgroundColor: Colors.orange,
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 25,),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(right: 12, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Budget per person',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 45,),
                Text('Set Your Minimum Budget: '
                    'RM ${minBudget.toStringAsFixed(2)}'),
                Slider(
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  value: minBudget,
                  onChanged: (value) {
                    setState(() {
                      minBudget = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
                Text('Set Your Maximum Budget: '
                    'RM ${maxBudget.toStringAsFixed(2)}'),
                Slider(
                  min: 0.0,
                  max: 100.0,
                  divisions: 20,
                  value: maxBudget,
                  onChanged: (value) {
                    setState(() {
                      maxBudget = value;
                    });
                  },
                  activeColor: Colors.orange,
                ),
              ],
            ),
          ),
          const SizedBox(height: 25,),
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.all(10.0),
            margin: const EdgeInsets.only(right: 12, left: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
                const SizedBox(height: 25,),
                ...categories.map((category) {
                  return CheckboxListTile(
                    title: Text(category),
                    value: selectedCategories[category],
                    onChanged: (bool? value) {
                      _onCategoryChanged(category, value ?? false);
                    },
                    activeColor: Colors.orange,
                  );
                }).toList(),
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: Container(
        padding: EdgeInsets.all(16),
        child: ElevatedButton(
          child: Text(
            'Apply',
            style: TextStyle(fontSize: 18),
          ),
          onPressed: _onSubmit,
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            minimumSize: Size(double.infinity, 50),
          ),
        ),
      ),
    );
  }
}

class FilteredPlacesScreen extends StatelessWidget {
  final List<Place> filteredPlaces;

  FilteredPlacesScreen(this.filteredPlaces);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Filtered Places'),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Container(
          width: 780.0, // Set your desired width here
          child: ListView.builder(
            itemCount: filteredPlaces.length,
            itemBuilder: (context, index) {
              Place place = filteredPlaces[index];
              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PlaceDetailPage(place: place),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[200], // Add a border
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.asset(
                        place.imagePath,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      place.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          place.category,
                          style: TextStyle(
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        Text(
                          place.minPrice == 0
                              ? 'Free Entry'
                              : 'Price Range: '
                              'RM ${place.minPrice.toStringAsFixed(2)} - '
                              'RM ${place.maxPrice.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.green,
                          ),
                        ), // Display the price
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

