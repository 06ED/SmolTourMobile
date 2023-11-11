import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';

@immutable
abstract class CreateArtObjectEvent {}

class ArtObjectStartCreating extends CreateArtObjectEvent {
  final String title;
  final String description;
  final double lat;
  final double lon;
  final Uint8List img;
  final String path;
  final File file;

  ArtObjectStartCreating({
    required this.title,
    required this.description,
    required this.lon,
    required this.lat,
    required this.img,
    required this.path,
    required this.file
  });
}

class ArtObjectCreated extends CreateArtObjectEvent {}
