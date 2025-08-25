import 'package:equatable/equatable.dart';

class TestState extends Equatable {
  final List<Map<String, dynamic>> questions;
  final int currentIndex;
  final Map<int, String> answers;
  final int remainingSeconds;
  final bool isSubmitted;
  final bool isLoading;

  const TestState({
    this.questions = const [],
    this.currentIndex = 0,
    this.answers = const {},
    this.remainingSeconds = 120 * 60, // 120 mins
    this.isSubmitted = false,
    this.isLoading = false,
  });

  TestState copyWith({
    List<Map<String, dynamic>>? questions,
    int? currentIndex,
    Map<int, String>? answers,
    int? remainingSeconds,
    bool? isSubmitted,
    bool? isLoading,
  }) {
    return TestState(
      questions: questions ?? this.questions,
      currentIndex: currentIndex ?? this.currentIndex,
      answers: answers ?? this.answers,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      isSubmitted: isSubmitted ?? this.isSubmitted,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props =>
      [questions, currentIndex, answers, remainingSeconds, isSubmitted, isLoading];
}