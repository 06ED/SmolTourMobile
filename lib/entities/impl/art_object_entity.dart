import '../entity.dart';

class ArtObjectEntity extends Entity {
  final String id, ownerId;
  final String title, description;
  final String photoId;
  final double lat, lon;

  ArtObjectEntity(
      {required this.id,
      required this.ownerId,
      required this.title,
      required this.description,
      required this.photoId,
      required this.lat,
      required this.lon});

  static ArtObjectEntity fromJson(Map jsonEntity) {
    return ArtObjectEntity(
        id: jsonEntity["id"],
        ownerId: jsonEntity["owner_id"],
        title: jsonEntity["title"],
        description: jsonEntity["description"],
        photoId: jsonEntity["image_id"],
        lat: jsonEntity["lat"],
        lon: jsonEntity["lon"]);
  }
}
