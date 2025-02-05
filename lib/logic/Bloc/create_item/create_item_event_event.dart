part of 'create_item_event_bloc.dart';



abstract class CreateItemEvent {}

class CreateItem extends CreateItemEvent {
  final String name;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final int posterUserId;
  final File? image;

  CreateItem({
    required this.name,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.posterUserId,
    this.image,
  });
}
