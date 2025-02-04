part of 'item_bloc.dart';

abstract class ItemEvent {}

class LoadUniqueItemNames extends ItemEvent {}
class SearchItems extends ItemEvent {
  final String? name;
  final double latitude;
  final double longitude;

  SearchItems({this.name, required this.latitude, required this.longitude});
}
