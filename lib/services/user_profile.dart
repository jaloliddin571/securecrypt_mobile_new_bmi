import 'dart:convert';

class UserProfile {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String? imagePath;

  UserProfile({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'imagePath': imagePath,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      imagePath: map['imagePath'],
    );
  }

  String toJson() => json.encode(toMap());

  factory UserProfile.fromJson(String source) => UserProfile.fromMap(json.decode(source));
}
