import 'dart:async';
import 'package:bloc/bloc.dart';
import '../../repositories/test_repo.dart';
import 'test_event.dart';
import 'test_state.dart';

class TestBloc extends Bloc<TestEvent, TestState> {
  final TestRepository _testRepository;
  Timer? _timer;

  TestBloc(this._testRepository) : super(const TestState()) {
    on<LoadTestQuestions>(_onLoadTestQuestions);
    on<SelectAnswer>(_onSelectAnswer);
    on<NextQuestion>(_onNextQuestion);
    on<PreviousQuestion>(_onPreviousQuestion);
    on<SubmitTest>(_onSubmitTest);
    on<TickTimer>(_onTickTimer);
  }

  Future<void> _onLoadTestQuestions(
      LoadTestQuestions event, Emitter<TestState> emit) async {
    emit(state.copyWith(isLoading: true));

    try {
      final questions = await _testRepository.fetchTestQuestions(event.testId);

      emit(state.copyWith(
        questions: questions,
        currentIndex: 0,
        isLoading: false,
        remainingSeconds: 120 * 60,
      ));

      _startTimer();
    } catch (e) {
      emit(state.copyWith(isLoading: false));
      print("Error loading questions: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.remainingSeconds > 0) {
        add(TickTimer());
      } else {
        add(SubmitTest());
      }
    });
  }

  void _onSelectAnswer(SelectAnswer event, Emitter<TestState> emit) {
    final updated = Map<int, String>.from(state.answers)
      ..[event.questionIndex] = event.answer;
    emit(state.copyWith(answers: updated));
  }

  void _onNextQuestion(NextQuestion event, Emitter<TestState> emit) {
    if (state.currentIndex < state.questions.length - 1) {
      emit(state.copyWith(currentIndex: state.currentIndex + 1));
    }
  }

  void _onPreviousQuestion(PreviousQuestion event, Emitter<TestState> emit) {
    if (state.currentIndex > 0) {
      emit(state.copyWith(currentIndex: state.currentIndex - 1));
    }
  }

  void _onSubmitTest(SubmitTest event, Emitter<TestState> emit) {
    _timer?.cancel();
    emit(state.copyWith(isSubmitted: true));
  }

  void _onTickTimer(TickTimer event, Emitter<TestState> emit) {
    emit(state.copyWith(remainingSeconds: state.remainingSeconds - 1));
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}