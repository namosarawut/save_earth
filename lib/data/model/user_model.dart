class UserModel {
  final int userId;
  final String email;
  final String username;
  final String? profileImageUrl;
  final String? firstName;
  final String? lastName;
  final String? phoneNumber;
  final String authType;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.email,
    required this.username,
    this.profileImageUrl,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    required this.authType,
    required this.createdAt,
  });

  // Factory method สำหรับแปลง JSON เป็น Object
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["user_id"],
      email: json["email"],
      username: json["username"],
      profileImageUrl: json["profile_image_url"],
      firstName: json["first_name"],
      lastName: json["last_name"],
      phoneNumber: json["phone_number"],
      authType: json["auth_type"],
      createdAt: DateTime.parse(json["created_at"]),
    );
  }

  // แปลง Object เป็น JSON (สำหรับกรณีต้องการ serialize)
  Map<String, dynamic> toJson() {
    return {
      "user_id": userId,
      "email": email,
      "username": username,
      "profile_image_url": profileImageUrl,
      "first_name": firstName,
      "last_name": lastName,
      "phone_number": phoneNumber,
      "auth_type": authType,
      "created_at": createdAt.toIso8601String(),
    };
  }
}
