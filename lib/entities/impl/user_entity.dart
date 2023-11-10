import '../entity.dart';

class UserEntity extends Entity {
  final int id;
  final String name;
  final String surname;
  final String mail;

  UserEntity(
      {required this.id,
      required this.name,
      required this.surname,
      required this.mail});
}
