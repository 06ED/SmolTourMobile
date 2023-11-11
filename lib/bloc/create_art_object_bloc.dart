import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smolaton/auth/auth_client.dart';
import 'package:smolaton/auth/auth_http_client.dart';
import 'create_art_object_event.dart';
import 'package:http_parser/src/media_type.dart';

part 'create_art_object_state.dart';

class CreateArtObjectBloc
    extends Bloc<CreateArtObjectEvent, CreateArtObjectState> {
  CreateArtObjectBloc() : super(CreateArtObjectInitial()) {
    on<ArtObjectStartCreating>((event, emit) async {
      final httpClient = AuthHttpClient(AuthClient());
      final request = http.MultipartRequest(
          "POST", Uri.parse("https://backend.umom.pro/photos/upload"));
      final pic = await http.MultipartFile.fromPath("photo", event.file.path,
          filename: event.file.path.split("/").last,
          contentType: MediaType("image", "png"));

      request.files.add(pic);
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final finalResponse = jsonDecode(utf8.decode(responseData));

      await httpClient.put("/arts/create",
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "title": event.title,
            "description": event.description,
            "image_id": finalResponse["file_id"],
            "lat": event.lat,
            "lon": event.lon
          }));

      emit(AddedArtObjectState());
    });
  }
}
