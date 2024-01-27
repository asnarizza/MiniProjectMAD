import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class ItineraryPage extends StatefulWidget {
  final List<Map<String, dynamic>> wishlistItems;

  ItineraryPage({Key? key, required this.wishlistItems}) : super(key: key);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  bool _isLoading = true;
  Completer<GoogleMapController> _controller = Completer();
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Position? _currentPosition;
  List<LatLng> _routePoints = [];
  List<String> travelTimes = [];

  @override
  void initState() {
    super.initState();
    requestLocationPermission();
  }

  Future<void> requestLocationPermission() async {
    var status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      print("Location permission denied.");
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      _currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      _sortWishlistItemsByDistance();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  Future<void> _sortWishlistItemsByDistance() async {
    try {
      Position currentPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      widget.wishlistItems.sort((a, b) {
        double distanceA = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          a['latitude'] as double,
          a['longitude'] as double,
        );

        double distanceB = Geolocator.distanceBetween(
          currentPosition.latitude,
          currentPosition.longitude,
          b['latitude'] as double,
          b['longitude'] as double,
        );

        return distanceA.compareTo(distanceB);
      });

      await _calculateTravelTimes(currentPosition);
      _addMarkersForPlaces(widget.wishlistItems);
      _fetchRoute();
    } catch (e) {
      print('Error getting location: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _calculateTravelTimes(Position currentPosition) async {
    LatLng startLocation = LatLng(
      currentPosition.latitude,
      currentPosition.longitude,
    );

    for (int i = 0; i < widget.wishlistItems.length; i++) {
      LatLng origin = i == 0 ? startLocation : LatLng(
          widget.wishlistItems[i - 1]['latitude'] as double,
          widget.wishlistItems[i - 1]['longitude'] as double);
      LatLng destination = LatLng(widget.wishlistItems[i]['latitude'] as double,
          widget.wishlistItems[i]['longitude'] as double);

      String travelTime = await fetchRouteWithTravelTime(origin, destination);
      travelTimes.add(travelTime);
    }
  }

  Future<void> _fetchRoute() async {
    if (_currentPosition == null || widget.wishlistItems.isEmpty) return;

    LatLng startLocation = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    List<LatLng> waypoints = [];
    for (int i = 0; i < widget.wishlistItems.length; i++) {
      Map<String, dynamic> place = widget.wishlistItems[i];
      LatLng location = LatLng(
          place['latitude'] as double, place['longitude'] as double);
      waypoints.add(location);
    }

    List<Polyline> polylines = [];

    LatLng? origin = startLocation;

    for (int i = 0; i < waypoints.length; i++) {
      LatLng destination = waypoints[i];

      try {
        Map<String, dynamic> routeData = await fetchRoute(origin, destination);
        List<LatLng> route = parseRoute(routeData);

        if (i == 0) {
          // Add the start location only once
          _routePoints.add(startLocation);
        }

        route.removeAt(0); // Remove the duplicate start point
        _routePoints.addAll(route);
        origin = destination;

        // Create a Polyline for this route segment
        final polyline = Polyline(
          polylineId: PolylineId('route_$i'),
          visible: true,
          points: route,
          color: Colors.blue,
          width: 4,
        );

        polylines.add(polyline);
      } catch (e) {
        print(e);
      }
    }

    setState(() {
      _polylines.addAll(polylines);
    });
  }

  Future<String> fetchRouteWithTravelTime(LatLng origin,
      LatLng destination) async {
    Map<String, dynamic> routeData = await fetchRoute(origin, destination);
    String duration = routeData['routes'][0]['legs'][0]['duration']['text'];
    return duration;
  }

  Future<Map<String, dynamic>> fetchRoute(LatLng? origin,
      LatLng? destination) async {
    String apiKey = 'AIzaSyC0ssko7ycawM_P4dN-_-Bpo4YFpY00m1k'; // Replace with your Google Maps API key
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${origin!.latitude},${origin.longitude}&'
        'destination=${destination!.latitude},${destination.longitude}&'
        'key=$apiKey';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load directions');
    }
  }

  List<LatLng> parseRoute(Map<String, dynamic> responseBody) {
    if (responseBody['status'] != 'OK') {
      throw Exception('Error from Google Maps API: ${responseBody['status']}');
    }

    List<LatLng> route = [];
    var steps = responseBody['routes'][0]['legs'][0]['steps'];

    for (var step in steps) {
      var startLocation = step['start_location'];
      var endLocation = step['end_location'];
      route.add(LatLng(startLocation['lat'], startLocation['lng']));
      route.add(LatLng(endLocation['lat'], endLocation['lng']));
    }

    return route;
  }

  void _addMarkersForPlaces(List<Map<String, dynamic>> places) {
    _markers.clear();

    for (int i = 0; i < places.length; i++) {
      Map<String, dynamic> place = places[i];
      LatLng location = LatLng(
          place['latitude'] as double, place['longitude'] as double);

      Marker marker = Marker(
        markerId: MarkerId(place['placeName'] as String),
        position: location,
        infoWindow: InfoWindow(
          title: place['placeName'] as String,
          snippet: 'Visit order: ${i + 1}',
        ),
      );

      _markers.add(marker);
    }
  }

  Future<void> _recalculateTravelTimes() async {
    if (_currentPosition == null) return;

    LatLng startLocation = LatLng(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
    );

    List<String> newTravelTimes = [];

    for (int i = 0; i < widget.wishlistItems.length; i++) {
      LatLng origin = i == 0 ? startLocation : LatLng(
          widget.wishlistItems[i - 1]['latitude'] as double,
          widget.wishlistItems[i - 1]['longitude'] as double);
      LatLng destination = LatLng(widget.wishlistItems[i]['latitude'] as double,
          widget.wishlistItems[i]['longitude'] as double);

      String travelTime = await fetchRouteWithTravelTime(origin, destination);
      newTravelTimes.add(travelTime);
    }

    setState(() {
      travelTimes = newTravelTimes;
    });
  }

  String calculateTotalTravelTime() {
    if (travelTimes.isEmpty) {
      return 'Calculating...';
    }
    Duration totalDuration = Duration();

    for (String time in travelTimes) {
      List<String> timeParts = time.split(' ');
      int minutes = int.parse(timeParts[0]);
      totalDuration += Duration(minutes: minutes);
    }

    int totalHours = totalDuration.inHours;
    int totalMinutes = totalDuration.inMinutes.remainder(60);

    return '$totalHours hours $totalMinutes minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Itinerary'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: _isLoading
                ? Center(child: CircularProgressIndicator())
                : GoogleMap(
              mapType: MapType.normal,
              initialCameraPosition: CameraPosition(
                target: _currentPosition != null
                    ? LatLng(
                    _currentPosition!.latitude,
                    _currentPosition!.longitude)
                    : LatLng(0, 0),
                zoom: 15.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              polylines: _polylines,
              markers: _markers,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 264.0),
            color: Colors.orange, // Set the color to orange
            child: Text(
              'Total Travel Time: ${calculateTotalTravelTime()}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 2,
            child: ReorderableListView.builder(
              itemCount: widget.wishlistItems.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) {
                    newIndex -= 1;
                  }
                  final item = widget.wishlistItems.removeAt(oldIndex);
                  widget.wishlistItems.insert(newIndex, item);
                  // Update markers and recalculate route
                  _addMarkersForPlaces(widget.wishlistItems);
                  _fetchRoute().then((_) => _recalculateTravelTimes());
                });
              },
              itemBuilder: (context, index) {
                final wishlistItem = widget.wishlistItems[index];
                return ReorderableDelayedDragStartListener(
                  index: index,
                  // uniques key for reorderableListView
                  key: ValueKey(wishlistItem),
                  child: ListTile(
                    key: ValueKey(wishlistItem['placeName']),
                    tileColor: Colors.white, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0), // Rounded corners
                      side: BorderSide(
                        color: Colors.orange, // Border color
                        width: 1.0,
                      ),
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 20.0),
                    leading: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.orange,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.place,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    title: Text(
                      wishlistItem['placeName'] as String,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Text(
                          'Visit order: ${index + 1}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.bold, // Bold
                            fontStyle: FontStyle.italic, // Italic
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Travel time: ${travelTimes.isNotEmpty ?
                          travelTimes[index] : 'Calculating...'}',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}