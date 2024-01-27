import 'package:custom_info_window/custom_info_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:melaka_wanderlust/models/map_marker.dart';

class InfoWindow extends StatefulWidget {
  const InfoWindow({Key? key}) : super(key: key);

  @override
  State<InfoWindow> createState() => _InfoWindowState();
}

class _InfoWindowState extends State<InfoWindow> {

  CustomInfoWindowController customInfoWindowController =
  CustomInfoWindowController();
  double? rating;

  final List<Marker> markers = <Marker>[];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  loadData() async {
    for (String type in [
      'attractions',
      'historicals',
      'beaches',
      'restaurants'
    ]) {
      QuerySnapshot querySnapshot =
      await FirebaseFirestore.instance.collection(type).get();

      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        PlaceInfo placeInfo = PlaceInfo(
          doc['name'],
          doc['imagePath'],
          doc['minPrice'],
          doc['maxPrice'],
          doc['briefDesc'],
          LatLng(
              doc['latLng']['latitude'],
              doc['latLng']['longitude'],
          ),
          type,
        );

        String markerIdValue = '$type${doc.id}';

        markers.add(
          Marker(
            markerId: MarkerId(markerIdValue),
            icon: BitmapDescriptor.defaultMarker,
            position: placeInfo.latLng,
            onTap: () {
              customInfoWindowController.addInfoWindow!(
                Container(
                  height: 700,
                  width: 300,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 300,
                        height: 130,
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage(placeInfo.imagePath),
                            fit: BoxFit.fitWidth,
                            filterQuality: FilterQuality.high,
                          ),
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                placeInfo.name,
                                style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 5),
                              Text(
                                placeInfo.minPrice == 0
                                    ? 'Free Entry'
                                    : 'Price: RM ${placeInfo.minPrice} '
                                    '- RM ${placeInfo.maxPrice}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.green,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                '${placeInfo.briefDesc}',
                                style: TextStyle(fontSize: 14),
                              ),
                              SizedBox(height: 5),
                              // Text(
                              //   '${rating}',
                              //   style: TextStyle(fontSize: 14),
                              // ),
                              if (rating != null)
                                Row(
                                  children: [
                                    Text('Rating: '),
                                    RatingBarIndicator(
                                      rating: rating!,
                                      itemBuilder: (context, index) =>
                                          Icon(Icons.star, color: Colors.amber),
                                      itemCount: 5,
                                      itemSize: 18.0,
                                      direction: Axis.horizontal,
                                    ),
                                  ],
                                ),
                              if (rating == null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4.0),
                                  child: Text('No reviews available'),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                placeInfo.latLng,
              );
            },
          ),
        );
      }
    }

    setState(() {});
  }


  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: LatLng(2.200844, 102.240143),
            zoom: 14.4746,
          ),
          markers: Set<Marker>.of(markers),
          onTap: (position) {
            customInfoWindowController.hideInfoWindow!();
          },
          onCameraMove: (position) {
            customInfoWindowController.onCameraMove!();
          },
          onMapCreated: (GoogleMapController controller) {
            customInfoWindowController.googleMapController = controller;
          },
        ),
        CustomInfoWindow(
          controller: customInfoWindowController,
          height: 200,
          width: 300,
          offset: 35,
        ),
      ],
    );
  }
}

