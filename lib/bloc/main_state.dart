part of 'main_bloc.dart';

@immutable
abstract class MainState {}

class MainInitial extends MainState {}

class MainLoadState extends MainState {
  final List<ArtObjectEntity> artObjects;

  MainLoadState({required this.artObjects});
}
