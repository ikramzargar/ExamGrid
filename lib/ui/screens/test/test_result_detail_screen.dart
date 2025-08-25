import 'package:flutter/material.dart';

class TestResultDetailScreen extends StatelessWidget {
  final String testName;
  final List<Map<String, dynamic>> questions;
  final Map<int, String> answers;
  final String filter; // correct / incorrect / skipped

  const TestResultDetailScreen({
    Key? key,
    required this.testName,
    required this.questions,
    required this.answers,
    required this.filter,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = questions.asMap().entries.where((entry) {
      final index = entry.key;
      final question = entry.value;
      final correctAnswer = question["answer"];
      final userAnswer = answers[index];

      if (filter == "correct" && userAnswer == correctAnswer) return true;
      if (filter == "incorrect" && userAnswer != null && userAnswer != correctAnswer) return true;
      if (filter == "unanswered" && userAnswer == null) return true;
      return false;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("$testName - ${filter[0].toUpperCase()}${filter.substring(1)} Answers"),
      ),
      body: ListView.builder(
        itemCount: filteredQuestions.length,
        itemBuilder: (context, i) {
          final index = filteredQuestions[i].key;
          final question = filteredQuestions[i].value;
          final correctAnswer = question["options"][question["answer"]];
          final userAnswer = answers[index] != null
              ? question["options"][answers[index]]
              : null;

          final isCorrect = userAnswer == correctAnswer;

          return Card(
            child: ExpansionTile(
              title: Text(
                question["title"] ?? "",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
              children: [
                ListTile(
                  title: Text("Your Answer: ${userAnswer ?? "Not answered"}"),
                ),
                ListTile(
                  title: Text("Correct Answer: $correctAnswer"),
                ),
                if (question["solution"] != null && question["solution"].isNotEmpty)
                  ListTile(
                    title: Text("Solution: ${question["solution"]}"),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}