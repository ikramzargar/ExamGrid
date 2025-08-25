import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'test_result_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  List<Map<String, dynamic>> _history = [];

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    String? data = await _secureStorage.read(key: "test_history");
    if (data != null && data.isNotEmpty) {
      try {
        final decoded = List<Map<String, dynamic>>.from(jsonDecode(data));
        setState(() {
          _history = decoded;
        });
      } catch (e) {
        debugPrint("Error decoding history: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Center(child: const Text("Test History"))),
      body: _history.isEmpty
          ? const Center(child: Text("No test history yet."))
          : ListView.builder(
        itemCount: _history.length,
        itemBuilder: (context, index) {
          final test = _history[index];

          final String testName = test["testName"] ?? "Unknown Test";
          final int correct = test["correct"] ?? 0;
          final int incorrect = test["incorrect"] ?? 0;
          final int unanswered = test["unanswered"] ?? 0;
          final double score =
              double.tryParse(test["score"].toString()) ?? 0.0;
          final String date = test["date"] ?? "";
          final List<Map<String, dynamic>> questions =
          List<Map<String, dynamic>>.from(test["questions"] ?? []);

          // build answers map from questions
          final Map<int, String> answers = {};
          for (int i = 0; i < questions.length; i++) {
            final userAnswer = questions[i]["userAnswer"];
            if (userAnswer != null) {
              answers[i] = userAnswer;
            }
          }

          return Card(
            margin: const EdgeInsets.all(12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(testName,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      Text("${score.toStringAsFixed(1)}%",
                          style: const TextStyle(
                              fontSize: 16, color: Colors.blue)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(date,
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),

                  const SizedBox(height: 16),

                  // Correct / Wrong / Unanswered tiles
                  _resultTile(
                    context: context,
                    title: "Correct Answers",
                    value: correct,
                    color: Colors.green,
                    filter: "correct",
                    testName: testName,
                    questions: questions,
                    answers: answers,
                  ),
                  _resultTile(
                    context: context,
                    title: "Wrong Answers",
                    value: incorrect,
                    color: Colors.red,
                    filter: "incorrect",
                    testName: testName,
                    questions: questions,
                    answers: answers,
                  ),
                  _resultTile(
                    context: context,
                    title: "Unanswered",
                    value: unanswered,
                    color: Colors.orange,
                    filter: "unanswered",
                    testName: testName,
                    questions: questions,
                    answers: answers,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _resultTile({
    required BuildContext context,
    required String title,
    required int value,
    required Color color,
    required String filter,
    required String testName,
    required List<Map<String, dynamic>> questions,
    required Map<int, String> answers,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestResultDetailScreen(
              testName: testName,
              questions: questions,
              answers: answers,
              filter: filter,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Text(title,
                style:
                const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
            const Spacer(),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, size: 16),
          ],
        ),
      ),
    );
  }
}