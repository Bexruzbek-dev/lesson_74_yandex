import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

class YandexMapService {
  static Future<List<PolylineMapObject>> getDirection(Point from, Point to) async {
    final result = await YandexPedestrian.requestRoutes(
      points: [
        RequestPoint(point: from, requestPointType: RequestPointType.wayPoint),
        RequestPoint(point: to, requestPointType: RequestPointType.wayPoint),
      ],
      avoidSteep: true,
      timeOptions: TimeOptions(),
    );

    final pedestrianResults = await result.$2;

    if (pedestrianResults.error != null) {
      print("Failed to get route: ${pedestrianResults.error}");
      return [];
    }

    return pedestrianResults.routes!.map((route) {
      return PolylineMapObject(
        mapId: MapObjectId(UniqueKey().toString()),
        polyline: route.geometry,
        strokeColor: Colors.orange,
        strokeWidth: 5,
      );
    }).toList();
  }

  static Future<Point?> searchPlace(Point query) async {
    final result = await YandexSearch.searchByText(
      geometry: Geometry.fromPolyline(Polyline(points: [])),
      searchText: "query",
      searchOptions: const SearchOptions(
        searchType: SearchType.geo,
      ),
    );

    final searchResult = await result.$2;

    if (searchResult.error != null) {
      print("Failed to find location: ${searchResult.error}");
      return null;
    }

    final firstItem = searchResult.items?.first;
    if (firstItem != null && firstItem.toponymMetadata != null) {
      return firstItem.toponymMetadata!.balloonPoint;
    } else {
      print("Location not found");
      return null;
    }
  }
}
