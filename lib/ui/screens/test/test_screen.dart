
import 'package:examgrid/ui/screens/test/test_result_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/test_bloc/test_bloc.dart';
import '../../../bloc/test_bloc/test_event.dart';
import '../../../bloc/test_bloc/test_state.dart';
import '../../../repositories/test_repo.dart';
import '../../widgets/loader.dart';

class TestScreen extends StatelessWidget {
  final String testId;
  final String testName;

  const TestScreen({super.key, required this.testId, required this.testName});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TestBloc(TestRepository())..add(LoadTestQuestions(testId)),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: MultiBlocListener(
          listeners: [
            // 🔹 Loader handling
            BlocListener<TestBloc, TestState>(
              listenWhen: (prev, curr) => prev.isLoading != curr.isLoading,
              listener: (context, state) {
                if (state.isLoading) {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const LogoLoader(message: 'Loading...'),
                  );
                } else {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context); // dismiss loader
                  }
                }
              },
            ),

            // 🔹 Navigate to result screen
            BlocListener<TestBloc, TestState>(
              listenWhen: (prev, curr) => prev.isSubmitted != curr.isSubmitted,
              listener: (context, state) {
                if (state.isSubmitted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ResultScreen(
                        questions: state.questions,
                        answers: state.answers,
                        testName: testName,
                      ),
                    ),
                  );
                }
              },
            ),
          ],
          child: BlocBuilder<TestBloc, TestState>(
            builder: (context, state) {
              if (state.questions.isEmpty) {
                return const Center(child: Text("No questions available"));
              }

              final question = state.questions[state.currentIndex];
              final remainingMinutes =
              (state.remainingSeconds ~/ 60).toString().padLeft(2, '0');
              final remainingSeconds =
              (state.remainingSeconds % 60).toString().padLeft(2, '0');
              final optionEntries = question["options"].entries.toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 12,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Center(
                        child: Row(
                          children: [
                            const SizedBox(width: 20),
                            const Icon(Icons.timer, color: Colors.white),
                            Text(
                              "$remainingMinutes:$remainingSeconds Minutes.",
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                context.read<TestBloc>().add(SubmitTest());
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white,
                              ),
                              child: const Text(
                                'End',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Top Section with logo
                  Container(
                    height: 150,
                    width: MediaQuery.of(context).size.width,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(50),
                        topRight: Radius.circular(50),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Image.asset(
                            'images/logo.png',
                            height: 130,
                            width: 130,
                          ),
                          const Text('Please Select the correct option'),
                        ],
                      ),
                    ),
                  ),

                  // Question + Options
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 0,horizontal: 20),
                      color: Colors.white,
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Text(
                            "Question ${state.currentIndex + 1} / ${state.questions.length}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            question["title"] ?? "",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Options Grid
                          Column(
                            children: List.generate(
                              (optionEntries.length / 2).ceil(),
                                  (rowIndex) {
                                final startIndex = rowIndex * 2;
                                final endIndex = (startIndex + 2)
                                    .clamp(0, optionEntries.length);

                                return Row(
                                  children: optionEntries
                                      .sublist(startIndex, endIndex)
                                      .map<Widget>((entry) {
                                    final optionKey = entry.key;
                                    final optionText = entry.value;
                                    final isSelected =
                                        state.answers[state.currentIndex] ==
                                            optionKey;

                                    return Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          context.read<TestBloc>().add(
                                            SelectAnswer(
                                              state.currentIndex,
                                              optionKey,
                                            ),
                                          );
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 0),
                                          child: Container(
                                            margin: const EdgeInsets.all(8),
                                            padding: const EdgeInsets.all(10),
                                            // Remove fixed height
                                            decoration: BoxDecoration(
                                              color: isSelected ? const Color(0xffffcbab) : Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: isSelected
                                                    ? Theme.of(context).colorScheme.secondary
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Colors.black12,
                                                  blurRadius: 6,
                                                  offset: Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: LayoutBuilder(
                                              builder: (context, constraints) {
                                                final span = TextSpan(
                                                  text: optionText,
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color: Colors.grey.shade800,
                                                  ),
                                                );

                                                final tp = TextPainter(
                                                  text: span,
                                                  maxLines: 4,
                                                  textDirection: TextDirection.ltr,
                                                );

                                                tp.layout(maxWidth: constraints.maxWidth);

                                                // Line height (roughly fontSize * 1.2 for padding)
                                                final lineHeight = (tp.size.height / tp.computeLineMetrics().length);

                                                // Detect actual line count
                                                final lineCount = tp.computeLineMetrics().length;

                                                // Base height is 70, add 10px if text goes beyond 2 lines
                                                final containerHeight = lineCount > 3 ? 80.0 : 70.0;

                                                return SizedBox(
                                                  height: containerHeight,
                                                  child: Center(
                                                    child: Text(
                                                      optionText,
                                                      textAlign: TextAlign.center,
                                                      maxLines: 4,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontSize: lineCount > 2 ? 12 : 14,
                                                        fontWeight: FontWeight.w500,
                                                        color: Colors.grey.shade800,
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                );
                              },
                            ).toList(),
                          ),

                          const Spacer(),

                          // Navigation Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton(
                                onPressed: state.currentIndex > 0
                                    ? () => context
                                    .read<TestBloc>()
                                    .add(PreviousQuestion())
                                    : null,
                                child: const Text("Previous"),
                              ),
                              if (state.currentIndex <
                                  state.questions.length - 1)
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<TestBloc>()
                                      .add(NextQuestion()),
                                  child: const Text("Next"),
                                )
                              else
                                ElevatedButton(
                                  onPressed: () => context
                                      .read<TestBloc>()
                                      .add(SubmitTest()),
                                  child: const Text("Submit"),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}