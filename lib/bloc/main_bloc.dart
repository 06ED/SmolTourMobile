import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:smolaton/entities/impl/art_object_entity.dart';
import 'package:smolaton/settings.dart';

part 'main_event.dart';

part 'main_state.dart';

class MainBloc extends Bloc<MainEvent, MainState> {
  MainBloc() : super(MainInitial()) {
    on<MainInitEvent>((event, emit) async {
      final client = http.Client();
      final artObjects = <ArtObjectEntity>[];

      try {
        final response = await client.get(Uri.parse("$kBaseUrl/arts/get/all"));
        final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as List;
        artObjects.addAll(decodedResponse.map((e) => ArtObjectEntity.fromJson(e)));
      } finally {
        client.close();
      }

      emit(MainLoadState(artObjects: artObjects));
    });
  }
}
