import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smolaton/bloc/main_bloc.dart';
import 'package:smolaton/utils/image_utils.dart';
import 'package:smolaton/utils/load_animation.dart';
import 'package:yandex_mapkit/yandex_mapkit.dart';

import '../entities/impl/art_object_entity.dart';

class MainRoute extends StatefulWidget {
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
        builder: (context, state) {
          if (state is MainLoadState) {
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 141, 211, 187),
              body: _getArtObjectsWidget(state.artObjects),
            );
          }
          return const LoadingAnimation();
        },
        listener: (context, state) {});
  }

  Widget _getArtObjectsWidget(List<ArtObjectEntity> artObjects) {
    return ListView.builder(
      itemCount: artObjects.length,
      itemBuilder: (context, index) => _buildArtObjectItem(artObjects[index]),
    );
  }

  Widget _buildArtObjectItem(ArtObjectEntity artObject) {
    return InkWell(
      onTap: () {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    FullArtObjectWidget(artObject: artObject)));
      },
      child: Container(
          margin: const EdgeInsets.all(15),
          padding: const EdgeInsets.all(10),
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(15),
              ),
              color: Color.fromARGB(255, 205, 234, 225)),
          child: Wrap(
            runSpacing: 15,
            alignment: WrapAlignment.spaceAround,
            children: [
              ClipRRect(
                  borderRadius: const BorderRadius.all(Radius.circular(15)),
                  child: Hero(
                    tag: artObject.id,
                    child: Image.network(
                      ImageUtils.getImageUrl(artObject.photoId),
                      width: double.infinity,
                      height: 200,
                      fit: BoxFit.fitWidth,
                    ),
                  )),
              Text(
                artObject.title,
                style: const TextStyle(fontSize: 24),
              ),
            ],
          )),
    );
  }

  Widget _generateButton(
      {required VoidCallback onPressed, required Widget child}) {
    return TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: const Color.fromARGB(200, 0, 0, 0),
          foregroundColor: Colors.white,
          textStyle: const TextStyle(color: Colors.white, fontSize: 20),
        ),
        child: Container(padding: const EdgeInsets.all(5), child: child));
  }
}

class FullArtObjectWidget extends StatefulWidget {
  final ArtObjectEntity artObject;

  const FullArtObjectWidget({super.key, required this.artObject});

  @override
  State<FullArtObjectWidget> createState() => _FullArtObjectWidgetState();
}

class _FullArtObjectWidgetState extends State<FullArtObjectWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(200, 205, 234, 225),
        title: Text(
          widget.artObject.title,
          style: const TextStyle(
            fontSize: 28,
          ),
        ),
      ),
      backgroundColor: const Color.fromARGB(255, 141, 211, 187),
      body: Column(
        children: [
          Stack(
            children: [
              Hero(
                tag: widget.artObject.id,
                child: Image.network(
                  ImageUtils.getImageUrl(widget.artObject.photoId),
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.fitWidth,
                ),
              )
            ],
          ),
          Container(
            margin: const EdgeInsets.all(15),
            child: Text(
              widget.artObject.description,
              style: const TextStyle(
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 150,
        height: 70,
        child: RawMaterialButton(
          fillColor: const Color.fromARGB(200, 0, 0, 0),
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20))),
          elevation: 0.0,
          child: const Text(
            "На карте",
            style: TextStyle(fontSize: 24, color: Colors.white),
          ),
          onPressed: () {},
        ),
      ),
    );
  }
}

class MapWidget extends StatefulWidget {
  final ArtObjectEntity artObject;

  const MapWidget({super.key, required this.artObject});

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  @override
  Widget build(BuildContext context) {
    return const YandexMap();
  }
}
