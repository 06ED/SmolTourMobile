import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smolaton/bloc/create_art_object_bloc.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../auth/auth_client.dart';
import '../auth/auth_http_client.dart';
import '../bloc/create_art_object_event.dart';

class CreateArtObjectRoute extends StatefulWidget {
  const CreateArtObjectRoute({super.key});

  @override
  State<CreateArtObjectRoute> createState() => _CreateArtObjectRouteState();
}

class _CreateArtObjectRouteState extends State<CreateArtObjectRoute> {
  final _formKey = GlobalKey<FormState>();

  File? _image;

  GeoObject? _object;
  GeoObject? _tempObject;
  bool isMap = false;
  final mapObjects = <PlacemarkMapObject>[];
  final mapControllerCompleter = Completer<YandexMapController>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  selectFile() async {
    final file = await FilePicker.platform.pickFiles(
        type: FileType.custom, allowedExtensions: ["png", "jpg", "jpeg"]);

    if (file != null) {
      setState(() {
        _image = File(file.files.single.path!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CreateArtObjectBloc, CreateArtObjectState>(
        builder: (context, state) {
          if (isMap) {
            return Scaffold(
              appBar: _getAppBar(),
              body: YandexMap(
                mapObjects: mapObjects,
                onMapCreated: (controller) async {
                  mapControllerCompleter.complete(controller);
                  await _moveToCurrentLocation(54.7903112, 32.05036629999995);
                },
                onObjectTap: (geoObject) => setState(() {
                  _tempObject = geoObject;
                  mapObjects.clear();
                  mapObjects.add(
                    PlacemarkMapObject(
                      mapId: const MapObjectId("main_point"),
                      point: Point(
                        latitude: geoObject.geometry.first.point!.latitude,
                        longitude: geoObject.geometry.first.point!.longitude,
                      ),
                      icon: PlacemarkIcon.single(
                        PlacemarkIconStyle(
                            image: BitmapDescriptor.fromAssetImage(
                                "assets/location.png"),
                            rotationType: RotationType.rotate),
                      ),
                    ),
                  );
                }),
              ),
              floatingActionButton: _tempObject == null
                  ? null
                  : FloatingActionButton(
                      backgroundColor: const Color.fromARGB(255, 141, 211, 187),
                      onPressed: () => setState(() {
                        _object = _tempObject;
                        _tempObject = null;
                        isMap = false;
                      }),
                      child: const Icon(
                        Icons.add,
                        size: 20,
                      ),
                    ),
            );
          }
          return Scaffold(
            appBar: _getAppBar(),
            backgroundColor: const Color.fromARGB(255, 141, 211, 187),
            body: Center(
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.all(30),
                decoration: const BoxDecoration(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                    color: Color.fromARGB(255, 205, 234, 225)),
                child: Form(
                  key: _formKey,
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    runSpacing: 20,
                    children: [
                      _getFormInput("Название", _titleController, 1),
                      _getFormInput("Описание", _descriptionController, 7),
                      _getButton(
                        () async => await selectFile(),
                        Text(
                          _image == null
                              ? "Выберите файл..."
                              : _image!.path.split("/").last,
                          style: const TextStyle(
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                      _getButton(
                        () => setState(() {
                          isMap = true;
                        }),
                        Text(
                          _getLocationName(),
                          style: const TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                      TextButton(
                          style: TextButton.styleFrom(
                            backgroundColor: const Color.fromARGB(180, 0, 0, 0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(
                              vertical: 20,
                              horizontal: 115,
                            ),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate() && _image != null) {
                              context.read<CreateArtObjectBloc>().add(
                                    ArtObjectStartCreating(
                                      title: _titleController.text,
                                      description: _descriptionController.text,
                                      lat: _object!
                                          .geometry.first.point!.latitude,
                                      lon: _object!
                                          .geometry.first.point!.longitude,
                                      img: _image!.readAsBytesSync(),
                                      path: _image!.path,
                                      file: _image!
                                    ),
                                  );
                            }
                          },
                          child: const Text(
                            "Создать",
                            style: TextStyle(
                              fontSize: 22,
                              color: Colors.white,
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
        listener: (context, state) {});
  }

  AppBar _getAppBar() => AppBar(
        title: const Text("Добавление арт-обьекта"),
        backgroundColor: const Color.fromARGB(255, 205, 234, 225),
      );

  String _getLocationName() {
    if (_object == null) {
      return "Выбрать локацию";
    }
    if (_object!.name != "") {
      return _object!.name;
    }
    if (_object!.descriptionText != "") {
      return _object!.descriptionText;
    }
    return "Точка выбрана";
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
          zoom: 12,
        ),
      ),
    );
  }

  Widget _getButton(VoidCallback onPress, Widget child) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onPress,
      child: Container(
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 80),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.all(Radius.circular(10)),
            border: Border.all(
              color: const Color.fromARGB(180, 0, 0, 0),
            ),
          ),
          child: child),
    );
  }

  Widget _getFormInput(
      String hintText, TextEditingController controller, int maxLines) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.all(Radius.circular(10)),
      ),
      child: TextFormField(
        maxLines: maxLines,
        controller: controller,
        style: const TextStyle(
          color: Colors.black,
        ),
        decoration: InputDecoration(
          border: const OutlineInputBorder(borderSide: BorderSide.none),
          hintText: hintText,
        ),
      ),
    );
  }
}
