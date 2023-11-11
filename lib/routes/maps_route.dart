import 'dart:async';

import 'package:flutter/material.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../entities/impl/art_object_entity.dart';
import '../utils/load_animation.dart';
import '../utils/location_utils.dart';

class MapWidget extends StatefulWidget {
  final ArtObjectEntity artObject;

  const MapWidget({super.key, required this.artObject});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  final mapObjects = <PlacemarkMapObject>[];
  final mapControllerCompleter = Completer<YandexMapController>();
  final MapObjectId mapObjectId = const MapObjectId("start_point");

  @override
  Widget build(BuildContext context) {
    final point = PlacemarkMapObject(
      mapId: mapObjectId,
      point: Point(
          latitude: widget.artObject.lat, longitude: widget.artObject.lon),
      icon: PlacemarkIcon.single(
        PlacemarkIconStyle(
            image: BitmapDescriptor.fromAssetImage("assets/location.png"),
            rotationType: RotationType.rotate),
      ),
    );
    mapObjects.add(point);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.artObject.title,
          style: const TextStyle(fontSize: 22),
        ),
        backgroundColor: const Color.fromARGB(200, 205, 234, 225),
      ),
      body: Column(
        children: [
          Expanded(
              child: YandexMap(
            mapObjects: mapObjects,
            onMapCreated: (controller) async {
              mapControllerCompleter.complete(controller);
              await _moveToCurrentLocation(mapObjects.first.point.latitude,
                  mapObjects.first.point.longitude);
            },
          )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 141, 211, 187),
        onPressed: () {
          setState(() async {
            final currentLocation = await LocationUtils.determinePosition();
            final endPoint = PlacemarkMapObject(
              mapId: const MapObjectId("end_point"),
              point: Point(
                  latitude: currentLocation.latitude,
                  longitude: currentLocation.longitude),
              icon: PlacemarkIcon.single(PlacemarkIconStyle(
                  image: BitmapDescriptor.fromAssetImage(
                      "assets/end_location.png"),
                  rotationType: RotationType.rotate)),
            );
            final yandexDriving = YandexDriving.requestRoutes(
                points: [
                  RequestPoint(
                      point: mapObjects.first.point,
                      requestPointType: RequestPointType.wayPoint),
                  RequestPoint(
                      point: endPoint.point,
                      requestPointType: RequestPointType.wayPoint)
                ],
                drivingOptions: const DrivingOptions(
                    initialAzimuth: 0, routesCount: 1, avoidTolls: true));
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DrivingPageWidget(
                  result: yandexDriving.result,
                  session: yandexDriving.session,
                  start: mapObjects.first,
                  end: endPoint,
                  artObject: widget.artObject,
                ),
              ),
            );
          });
        },
        child: const Icon(
          Icons.navigation_outlined,
          size: 35,
        ),
      ),
    );
  }

  Future<void> _moveToCurrentLocation(double lat, double lon) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: lat,
            longitude: lon,
          ),
          zoom: 8,
        ),
      ),
    );
  }
}

class DrivingPageWidget extends StatefulWidget {
  final Future<DrivingSessionResult> result;
  final DrivingSession session;
  final PlacemarkMapObject start;
  final PlacemarkMapObject end;
  final ArtObjectEntity artObject;

  const DrivingPageWidget({
    required this.result,
    required this.session,
    required this.start,
    required this.end,
    required this.artObject,
    super.key,
  });

  @override
  State<DrivingPageWidget> createState() => _DrivingPageWidgetState();
}

class _DrivingPageWidgetState extends State<DrivingPageWidget> {
  final mapControllerCompleter = Completer<YandexMapController>();
  late final List<MapObject> mapObjects = [widget.start, widget.end];
  bool _progress = true;

  final List<DrivingSessionResult> results = [];

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void dispose() {
    super.dispose();

    _close();
  }

  @override
  Widget build(BuildContext context) {
    if (_progress) {
      return const LoadingAnimation();
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Маршрут "${widget.artObject.title}"',
          style: const TextStyle(fontSize: 18),
        ),
        backgroundColor: const Color.fromARGB(200, 205, 234, 225),
      ),
      body: YandexMap(
        mapObjects: mapObjects,
        onMapCreated: (controller) async {
          mapControllerCompleter.complete(controller);
          await _moveToCurrentLocation(
              widget.start.point.latitude, widget.start.point.longitude);
        },
      ),
    );
  }

  Future<void> _close() async {
    await widget.session.close();
  }

  Future<void> _init() async {
    await _handleResult(await widget.result);
  }

  Future<void> _handleResult(DrivingSessionResult result) async {
    setState(() {
      _progress = false;
    });

    if (result.error != null) {
      return;
    }

    setState(() {
      results.add(result);
    });

    setState(() {
      final route = result.routes!.first;
      mapObjects.add(PolylineMapObject(
        mapId: const MapObjectId("route_polyline"),
        polyline: Polyline(points: route.geometry),
        strokeColor: const Color.fromARGB(200, 0, 0, 0),
        strokeWidth: 3,
      ));
    });
  }

  Future<void> _moveToCurrentLocation(double lat, double lon) async {
    (await mapControllerCompleter.future).moveCamera(
      animation: const MapAnimation(type: MapAnimationType.linear, duration: 1),
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: Point(
            latitude: lat,
            longitude: lon,
          ),
          zoom: 13,
        ),
      ),
    );
  }
}
