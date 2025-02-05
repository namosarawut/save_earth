class ContactInfo {
  final String firstName;
  final String lastName;
  final String phoneNumber;

  ContactInfo({
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      firstName: json["first_name"],
      lastName: json["last_name"],
      phoneNumber: json["phone_number"],
    );
  }
}

class User {
  final int userId;
  final String username;
  final ContactInfo contact;

  User({
    required this.userId,
    required this.username,
    required this.contact,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json["user_id"],
      username: json["username"],
      contact: ContactInfo.fromJson(json["contact"]),
    );
  }
}

class Item {
  final int itemId;
  final String name;
  final String imageUrl;
  final String category;
  final String description;
  final String latitude;
  final String longitude;
  final String status;
  final DateTime createdAt;
  final User postedBy;

  Item({
    required this.itemId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    required this.postedBy,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json["item_id"],
      name: json["name"],
      imageUrl: json["image_url"],
      category: json["category"],
      description: json["description"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
      postedBy: User.fromJson(json["posted_by"]),
    );
  }
}

class FavoriteModel {
  final int favoriteId;
  final Item item;
  final DateTime addedAt;

  FavoriteModel({
    required this.favoriteId,
    required this.item,
    required this.addedAt,
  });

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(
      favoriteId: json["favorite_id"],
      item: Item.fromJson(json["item"]),
      addedAt: DateTime.parse(json["added_at"]),
    );
  }
}
