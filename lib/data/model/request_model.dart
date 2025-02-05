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
  final String latitude;
  final String longitude;
  final User postedBy;

  Item({
    required this.itemId,
    required this.name,
    required this.imageUrl,
    required this.category,
    required this.latitude,
    required this.longitude,
    required this.postedBy,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      itemId: json["item_id"],
      name: json["name"],
      imageUrl: json["image_url"],
      category: json["category"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      postedBy: User.fromJson(json["posted_by"]),
    );
  }
}

class RequestModel {
  final int requestId;
  final Item item;
  final String reason;
  final String status;
  final DateTime createdAt;

  RequestModel({
    required this.requestId,
    required this.item,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory RequestModel.fromJson(Map<String, dynamic> json) {
    return RequestModel(
      requestId: json["request_id"],
      item: Item.fromJson(json["item"]),
      reason: json["reason"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}
