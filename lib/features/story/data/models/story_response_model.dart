import 'package:equatable/equatable.dart';
import 'story_model.dart';

class StoryResponseModel extends Equatable {
  final List<StoryModel> stories;
  final int currentPage;
  final int totalPages;

  const StoryResponseModel({
    required this.stories,
    required this.currentPage,
    required this.totalPages,
  });

  factory StoryResponseModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? {};
    final storiesData = data['stories'] as List<dynamic>? ?? [];

    return StoryResponseModel(
      stories: storiesData
          .map((story) => StoryModel.fromJson(story as Map<String, dynamic>))
          .toList(),
      currentPage: (data['pagination']?['currentPage'] as int?) ?? 1,
      totalPages: (data['pagination']?['totalPages'] as int?) ?? 0,
    );
  }

  @override
  List<Object?> get props => [stories, currentPage, totalPages];
}
