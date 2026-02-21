import 'package:equatable/equatable.dart';
import '../../data/models/story_model.dart';

enum StoryStatus { initial, loading, success, error, creating, deleting }

class StoryState extends Equatable {
  final StoryStatus status;
  final List<StoryModel> stories;
  final String? errorMessage;
  final int currentPage;
  final int totalPages;

  const StoryState({
    this.status = StoryStatus.initial,
    this.stories = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.totalPages = 0,
  });

  StoryState copyWith({
    StoryStatus? status,
    List<StoryModel>? stories,
    String? errorMessage,
    int? currentPage,
    int? totalPages,
  }) {
    return StoryState(
      status: status ?? this.status,
      stories: stories ?? this.stories,
      errorMessage: errorMessage,
      currentPage: currentPage ?? this.currentPage,
      totalPages: totalPages ?? this.totalPages,
    );
  }

  @override
  List<Object?> get props => [
    status,
    stories,
    errorMessage,
    currentPage,
    totalPages,
  ];
}
