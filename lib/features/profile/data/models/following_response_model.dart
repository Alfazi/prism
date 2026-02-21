import 'package:equatable/equatable.dart';
import 'following_user_model.dart';

class FollowingResponseModel extends Equatable {
  final int totalItems;
  final List<FollowingUserModel> users;
  final int totalPages;
  final int currentPage;

  const FollowingResponseModel({
    required this.totalItems,
    required this.users,
    required this.totalPages,
    required this.currentPage,
  });

  factory FollowingResponseModel.fromJson(Map<String, dynamic> json) {
    return FollowingResponseModel(
      totalItems: json['totalItems'] as int,
      users: (json['users'] as List<dynamic>)
          .map((e) => FollowingUserModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalPages: json['totalPages'] as int,
      currentPage: json['currentPage'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalItems': totalItems,
      'users': users.map((e) => e.toJson()).toList(),
      'totalPages': totalPages,
      'currentPage': currentPage,
    };
  }

  @override
  List<Object?> get props => [totalItems, users, totalPages, currentPage];
}
