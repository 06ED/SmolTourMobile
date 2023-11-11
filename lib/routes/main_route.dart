import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smolaton/bloc/main_bloc.dart';
import 'package:smolaton/utils/image_utils.dart';
import 'package:smolaton/utils/load_animation.dart';

import '../entities/impl/art_object_entity.dart';
import 'maps_route.dart';

class MainRoute extends StatefulWidget {
  const MainRoute({super.key});

  @override
  State<MainRoute> createState() => _MainRouteState();
}

class _MainRouteState extends State<MainRoute> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<MainBloc, MainState>(
        builder: (context, state) {
          if (state is MainLoadState) {
            return Scaffold(
              backgroundColor: const Color.fromARGB(255, 141, 211, 187),
              body: _getArtObjectsWidget(state.artObjects),
              floatingActionButton: FloatingActionButton(
                backgroundColor: const Color.fromARGB(255, 205, 234, 225),
                onPressed: () =>
                    Navigator.pushNamed(context, "/create_art_object"),
                child: const Icon(
                  Icons.add,
                  size: 30,
                ),
              ),
            );
          }
          return const LoadingAnimation();
        },
        listener: (context, state) {});
  }

  Widget _getArtObjectsWidget(List<ArtObjectEntity> artObjects) {
    return RefreshIndicator(
        key: _refreshIndicatorKey,
        color: Colors.white,
        backgroundColor: const Color.fromARGB(170, 0, 0, 0),
        strokeWidth: 2,
        onRefresh: () async {
          context.read<MainBloc>().add(MainInitEvent());
          return Future<void>.delayed(const Duration(seconds: 4));
        },
        // Pull from top to show refresh indicator.
        child: ListView.builder(
          itemCount: artObjects.length,
          itemBuilder: (context, index) =>
              _buildArtObjectItem(artObjects[index]),
        ),
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
          onPressed: () =>
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          MapWidget(artObject: widget.artObject))),
        ),
      ),
    );
  }
}
