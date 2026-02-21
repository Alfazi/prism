import 'package:equatable/equatable.dart';

class StoryUserModel extends Equatable {
  final String id;
  final String name;
  final String username;
  final String? profilePictureUrl;

  const StoryUserModel({
    required this.id,
    required this.name,
    required this.username,
    this.profilePictureUrl,
  });

  factory StoryUserModel.fromJson(Map<String, dynamic> json) {
    return StoryUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Unknown',
      username: json['username'] as String? ?? 'unknown',
      profilePictureUrl: json['profilePictureUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'username': username,
      'profilePictureUrl': profilePictureUrl,
    };
  }

  @override
  List<Object?> get props => [id, name, username, profilePictureUrl];
}
