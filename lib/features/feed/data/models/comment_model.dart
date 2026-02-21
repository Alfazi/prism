import 'package:equatable/equatable.dart';
import 'comment_user_model.dart';

class CommentModel extends Equatable {
  final String id;
  final String comment;
  final CommentUserModel user;

  const CommentModel({
    required this.id,
    required this.comment,
    required this.user,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'] as String? ?? '',
      comment: json['comment'] as String? ?? '',
      user: CommentUserModel.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'comment': comment, 'user': user.toJson()};
  }

  @override
  List<Object?> get props => [id, comment, user];
}
