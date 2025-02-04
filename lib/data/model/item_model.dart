class ItemModel {
  final int itemId;
  final String name;
  final String imageUrl;
  final String category;
  final String description;
  final double latitude;
  final double longitude;
  final String status;
  final DateTime createdAt;
  final int posterUserId;
  final double distance;

  ItemModel({
    required this.itemId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.posterUserId,
    required this.distance,
  });

  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      itemId: json["item_id"],
      name: json["name"],
      imageUrl: json["image_url"].toString(),
      category: json["category"],
      description: json["description"],
      latitude: double.parse(json["latitude"]),
      longitude: double.parse(json["longitude"]),
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
      posterUserId: json["poster_user_id"],
      distance: json["distance"].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "item_id": itemId,
      "name": name,
      "image_url": imageUrl,
      "category": category,
      "description": description,
      "latitude": latitude.toString(),
      "longitude": longitude.toString(),
      "status": status,
      "created_at": createdAt.toIso8601String(),
      "poster_user_id": posterUserId,
      "distance": distance,
    };
  }
}
