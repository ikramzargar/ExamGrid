import 'package:equatable/equatable.dart';

abstract class TestEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadTestQuestions extends TestEvent {
  final String testId; // e.g., "test1"
  LoadTestQuestions(this.testId);
}

class SelectAnswer extends TestEvent {
  final int questionIndex;
  final String answer;
  SelectAnswer(this.questionIndex, this.answer);
}

class NextQuestion extends TestEvent {}
class PreviousQuestion extends TestEvent {}
class SubmitTest extends TestEvent {}
class TickTimer extends TestEvent {}