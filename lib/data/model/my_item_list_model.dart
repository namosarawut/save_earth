class RequestUser {
  final int userId;
  final String username;
  final String firstName;
  final String lastName;
  final String phoneNumber;

  RequestUser({
    required this.userId,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.phoneNumber,
  });

  factory RequestUser.fromJson(Map<String, dynamic> json) {
    return RequestUser(
      userId: json["user_id"],
      username: json["username"],
      firstName: json["contact"]["first_name"],
      lastName: json["contact"]["last_name"],
      phoneNumber: json["contact"]["phone_number"],
    );
  }
}

class Request {
  final int requestId;
  final RequestUser requestBy;
  final String reason;
  final String status;
  final DateTime createdAt;

  Request({
    required this.requestId,
    required this.requestBy,
    required this.reason,
    required this.status,
    required this.createdAt,
  });

  factory Request.fromJson(Map<String, dynamic> json) {
    return Request(
      requestId: json["request_id"],
      requestBy: RequestUser.fromJson(json["request_by"]),
      reason: json["reason"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }
}

class ItemListModel {
  final int itemId;
  final String name;
  final String imageUrl;
  final String category;
  final String description;
  final String latitude;
  final String longitude;
  final String status;
  final DateTime createdAt;
  final int posterUserId;
  final List<Request> requests;

  ItemListModel({
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
    required this.requests,
  });

  factory ItemListModel.fromJson(Map<String, dynamic> json) {
    return ItemListModel(
      itemId: json["item_id"],
      name: json["name"],
      imageUrl: json["image_url"],
      category: json["category"],
      description: json["description"],
      latitude: json["latitude"],
      longitude: json["longitude"],
      status: json["status"],
      createdAt: DateTime.parse(json["created_at"]),
      posterUserId: json["poster_user_id"],
      requests: (json["requests"] as List).map((r) => Request.fromJson(r)).toList(),
    );
  }
}
