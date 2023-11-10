import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:smolaton/settings.dart';

class ImageUtils {
  static final _client = http.Client();

  static String getImageUrl(String photoId) =>
      "$kBaseUrl/photos/download?id=$photoId";

  static Future<String> uploadImage(Uint8List photo) async {
    final response =
        await _client.post(Uri.parse("$kBaseUrl/photos/upload"), body: photo);
    final decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

    return decodedResponse["file_id"];
  }
}
