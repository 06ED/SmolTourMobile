import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smolaton/auth/auth_client.dart';
import 'package:smolaton/auth/auth_http_client.dart';
import 'dart:io';
import 'create_art_object_event.dart';

part 'create_art_object_state.dart';

class CreateArtObjectBloc
    extends Bloc<CreateArtObjectEvent, CreateArtObjectState> {
  CreateArtObjectBloc() : super(CreateArtObjectInitial()) {
    on<ArtObjectStartCreating>((event, emit) async {
      log('bla bla');
      log('bla bla');
      final httpClient = AuthHttpClient(AuthClient());

      var request = http.MultipartRequest(
          "POST", Uri.parse("https://backend.umom.pro/photos/upload"));
      var pic = await http.MultipartFile.fromPath("photo", event.file.path, filename: "photo.png", contentType: M("image", "png"));
      request.files.add(pic);
      var response = await request.send();
      var responseData = await response.stream.toBytes();
      var responseString = String.fromCharCodes(responseData);
      log(responseString);

      log("bla bla");

      // await httpClient.put("/arts/create",
      //     headers: {"Content-Type": "application/json"},
      //     body: jsonEncode({
      //       "title": event.title,
      //       "description": event.description,
      //       "photo_id": ["file_id"],
      //       "lat": event.lat,
      //       "lon": event.lon
      //     }));
    });
  }
}
