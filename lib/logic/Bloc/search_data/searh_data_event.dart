part of 'searh_data_bloc.dart';


abstract class  SearchDataEvent {}
class SearchItems extends SearchDataEvent {
  final String? name;
  final double latitude;
  final double longitude;

  SearchItems({this.name, required this.latitude, required this.longitude});
}
// class GetItemsByCategory extends SearchDataEvent {
//   final String categoryName;
//   GetItemsByCategory(this.categoryName);
// }
class GetItemsByCategory extends SearchDataEvent {
  final String category;
  final String latitude;
  final String longitude;

  GetItemsByCategory({
    required this.category,
    required this.latitude,
    required this.longitude,
  });
}