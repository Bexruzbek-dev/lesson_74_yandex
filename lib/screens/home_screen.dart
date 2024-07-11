import 'package:dars74_yandexmap/services/geolocator_service.dart';
import 'package:dars74_yandexmap/services/yandex_map_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late YandexMapController mapController;
  String currentLocationName = "";
  List<MapObject> markers = [];
  List<PolylineMapObject> polylines = [];
  List<Point> positions = [];
  Point? myLocation;
  Point najotTalim = const Point(
    latitude: 41.2856806,
    longitude: 69.2034646,
  );
  final TextEditingController searchController = TextEditingController();

  void onMapCreated(YandexMapController controller) {
    setState(() {
      mapController = controller;

      mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: najotTalim,
            zoom: 18,
          ),
        ),
      );
    });
  }

  void onCameraPositionChanged(
    CameraPosition position,
    CameraUpdateReason reason,
    bool finish,
  ) {
    myLocation = position.target;
    setState(() {});
  }

  void addMarker() async {
    if (myLocation == null) return;

    markers.add(
      PlacemarkMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        point: myLocation!,
        opacity: 1,
        icon: PlacemarkIcon.single(
          PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage("assets/placemark.png"),
            scale: 0.5,
          ),
        ),
      ),
    );

    positions.add(myLocation!);

    if (positions.length == 2) {
      polylines = await YandexMapService.getDirection(
        positions[0],
        positions[1],
      );
    }

    setState(() {});
  }

  void getMyCurrentLocation() async {
    await Geolocator.openLocationSettings();
    final myPosition = await GeolocatorService.getLocation();
    if (myPosition != null) {
      myLocation = Point(
        latitude: myPosition.latitude,
        longitude: myPosition.longitude,
      );
      setState(() {});
      mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: myLocation!,
            zoom: 14,
          ),
        ),
      );
    }
  }

  void searchPlaceAndShowRoute() async {
    if (searchController.text.isEmpty) return;
    final Point? destination = await YandexMapService.searchPlace(searchController.text);
    if (destination != null && myLocation != null) {
      positions = [myLocation!, destination];
      polylines = await YandexMapService.getDirection(myLocation!, destination);
      markers.add(
        PlacemarkMapObject(
          mapId: MapObjectId(UniqueKey().toString()),
          point: destination,
          opacity: 1,
          icon: PlacemarkIcon.single(
            PlacemarkIconStyle(
              image: BitmapDescriptor.fromAssetImage("assets/placemark.png"),
              scale: 0.5,
            ),
          ),
        ),
      );

      setState(() {});
      mapController.moveCamera(
        animation: const MapAnimation(
          type: MapAnimationType.smooth,
          duration: 1,
        ),
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: destination,
            zoom: 14,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: searchController,
          decoration: InputDecoration(
            hintText: "Search for streets or cities",
            suffixIcon: IconButton(
              icon: const Icon(Icons.search),
              onPressed: searchPlaceAndShowRoute,
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () async {
              currentLocationName = await YandexMapService.searchPlace(myLocation!);
              setState(() {});
            },
            icon: const Icon(Icons.search),
          ),
          IconButton(
            onPressed: () {
              mapController.moveCamera(CameraUpdate.zoomOut());
            },
            icon: const Icon(Icons.remove_circle),
          ),
          IconButton(
            onPressed: () {
              mapController.moveCamera(CameraUpdate.zoomIn());
            },
            icon: const Icon(Icons.add_circle),
          ),
        ],
      ),
      body: Stack(
        children: [
          YandexMap(
            onMapCreated: onMapCreated,
            onCameraPositionChanged: onCameraPositionChanged,
            mapType: MapType.map,
            mapObjects: [
              PlacemarkMapObject(
                mapId: const MapObjectId("najotTalim"),
                point: najotTalim,
                opacity: 1,
                icon: PlacemarkIcon.single(
                  PlacemarkIconStyle(
                    image: BitmapDescriptor.fromAssetImage("assets/placemark.png"),
                    scale: 0.5,
                  ),
                ),
              ),
              ...markers,
              ...polylines,
            ],
          ),
          const Align(
            child: Icon(
              Icons.place,
              size: 60,
              color: Colors.blue,
            ),
          ),
          Positioned(
            bottom: 45,
            left: 10,
            child: FloatingActionButton(
              onPressed: getMyCurrentLocation,
              child: const Icon(
                Icons.person,
                size: 30,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: addMarker,
        child: const Icon(Icons.add_location),
      ),
    );
  }
}
