import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:melaka_wanderlust/pages/place_detail.dart';

import '../models/place.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {

  List allResults = [];
  List resultList = [];
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    _searchController.addListener(_onSearchChanged);
    super.initState();
  }

  _onSearchChanged(){
    print(_searchController.text);
    searchResultList();
  }

  searchResultList(){
    var showResults = [];
    if(_searchController.text != ""){
      for(var result in allResults){
        var name = result['name'].toString().toLowerCase();
        if(name.contains(_searchController.text.toLowerCase())){
          showResults.add(result);
        }
      }
    }
    else {
      showResults = List.from(allResults);
    }

    setState(() {
      resultList = showResults;
    });

  }

  // beach
  getBeachStream() async {
    var data = await FirebaseFirestore.instance.
    collection('beaches').orderBy('name').get();

    setState(() {
      allResults = data.docs;
    });
    searchResultList();
  }

  // historical
  getHistoricalStream() async {
    var data = await FirebaseFirestore.instance
        .collection('historicals')
        .orderBy('name')
        .get();

    setState(() {
      allResults.addAll(data.docs); // Add data from historicals collection
    });
    searchResultList();
  }

  // attractions
  getAttractionStream() async {
    var data = await FirebaseFirestore.instance
        .collection('attractions')
        .orderBy('name')
        .get();

    setState(() {
      allResults.addAll(data.docs); // Add data from attractions collection
    });
    searchResultList();
  }

  // restaurants
  getRestaurantStream() async {
    var data = await FirebaseFirestore.instance
        .collection('restaurants')
        .orderBy('name')
        .get();

    setState(() {
      allResults.addAll(data.docs); // Add data from attractions collection
    });
    searchResultList();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    getBeachStream();
    getHistoricalStream();
    getAttractionStream();
    getRestaurantStream();
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: Text("Where to?"),
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search destinations',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              key: UniqueKey(),
              itemCount: resultList.length,
              itemBuilder: (context, index) {
                final place = Place.fromFirestore(resultList[index]);
                return ListTile(
                  title: Text(place.name),
                  onTap: () {
                    Navigator.of(context,  rootNavigator: true).push(
                      MaterialPageRoute(
                        builder: (context) =>
                            PlaceDetailPage(place: place),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

