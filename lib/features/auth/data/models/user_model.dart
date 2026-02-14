import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String? id;
  final String name;
  final String username;
  final String email;
  final String? role;
  final String? profilePictureUrl;
  final String? phoneNumber;
  final String? bio;
  final String? website;

  const UserModel({
    this.id,
    required this.name,
    required this.username,
    required this.email,
    this.role,
    this.profilePictureUrl,
    this.phoneNumber,
    this.bio,
    this.website,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      name: json['name'] as String? ?? 'Unknown',
      username: json['username'] as String? ?? 'unknown',
      email: json['email'] as String? ?? '',
      role: json['role'] as String?,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      bio: json['bio'] as String?,
      website: json['website'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'email': email,
      'role': role,
      'profilePictureUrl': profilePictureUrl,
      'phoneNumber': phoneNumber,
      'bio': bio,
      'website': website,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    username,
    email,
    role,
    profilePictureUrl,
    phoneNumber,
    bio,
    website,
  ];
}
