import 'package:equatable/equatable.dart';

class FollowingUserModel extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? profilePictureUrl;
  final String createdAt;

  const FollowingUserModel({
    required this.id,
    required this.username,
    required this.email,
    this.profilePictureUrl,
    required this.createdAt,
  });

  factory FollowingUserModel.fromJson(Map<String, dynamic> json) {
    return FollowingUserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      profilePictureUrl: json['profilePictureUrl'] as String?,
      createdAt: json['createdAt'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profilePictureUrl': profilePictureUrl,
      'createdAt': createdAt,
    };
  }

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    profilePictureUrl,
    createdAt,
  ];
}
