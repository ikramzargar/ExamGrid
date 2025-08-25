import 'dart:ui';
import 'dart:convert'; // ✅ Needed for jsonEncode/jsonDecode
import 'package:examgrid/routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'test_result_detail_screen.dart'; // ✅ Import detail screen

class ResultScreen extends StatefulWidget {
  final String testName;
  final List<Map<String, dynamic>> questions;
  final Map<int, String> answers;

  const ResultScreen({
    Key? key,
    required this.testName,
    required this.questions,
    required this.answers,
  }) : super(key: key);

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final formattedDate = DateFormat("dd-MM-yyyy , hh:mm a").format(DateTime.now());

  int correct = 0;
  int incorrect = 0;
  int unanswered = 0;
  double percentage = 0;

  @override
  void initState() {
    super.initState();
    _calculateResults();
  }

  void _calculateResults() {
    int c = 0, ic = 0, s = 0;
    for (int i = 0; i < widget.questions.length; i++) {
      final correctAnswer = widget.questions[i]["answer"];
      final userAnswer = widget.answers[i];

      if (userAnswer == null) {
        s++;
      } else if (userAnswer == correctAnswer) {
        c++;
      } else {
        ic++;
      }
    }

    setState(() {
      correct = c;
      incorrect = ic;
      unanswered = s;
      percentage = (c / widget.questions.length) * 100;
    });

    // ✅ Save properly
    _saveResults();
  }

  Future<void> _saveResults() async {
    final Map<String, dynamic> resultData = {
      "testName": widget.testName,
      "score": percentage.toStringAsFixed(1),
      "correct": correct,
      "incorrect": incorrect,
      "unanswered": unanswered,
      "date": formattedDate,
      "questions": widget.questions.asMap().entries.map((entry) {
        final index = entry.key;
        final q = entry.value;
        return {
          ...q,
          "userAnswer": widget.answers[index],
        };
      }).toList(),
    };

    // Fetch old history
    String? existingData = await _secureStorage.read(key: "test_history");

    List<Map<String, dynamic>> history = [];
    if (existingData != null && existingData.isNotEmpty) {
      try {
        history = List<Map<String, dynamic>>.from(jsonDecode(existingData));
      } catch (e) {
        history = []; // fallback if corrupted data
      }
    }

    // Add new result at the start
    history.insert(0, resultData);

    // Save back as JSON string
    await _secureStorage.write(
      key: "test_history",
      value: jsonEncode(history),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          const SizedBox(height: 80),

          // 📌 Title pill
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(30),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    widget.testName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // 📊 Circular Score
          CircularPercentIndicator(
            arcType: ArcType.HALF,
            radius: 80.0,
            lineWidth: 15.0,
            animation: true,
            percent: correct / widget.questions.length,
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "${percentage.toStringAsFixed(0)}%",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: Colors.white),
                ),
                const SizedBox(height: 15),
                const Text(
                  "Your Score",
                  style: TextStyle(fontSize: 23, color: Colors.white),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: Colors.green,
            backgroundColor: Colors.white,
            arcBackgroundColor: Colors.white,
          ),

          const SizedBox(height: 20),

          // 📌 Expandable bottom section
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(50),
                  topRight: Radius.circular(50),
                ),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _resultTile(
                      title: "Correct Answers",
                      value: correct,
                      color: Colors.green,
                      filter: "correct",
                    ),
                    _resultTile(
                      title: "Wrong Answers",
                      value: incorrect,
                      color: Colors.red,
                      filter: "incorrect",
                    ),
                    _resultTile(
                      title: "Unanswered",
                      value: unanswered,
                      color: Colors.orange,
                      filter: "unanswered",
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12)),
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.testHistory);
                          },
                          child: const Text(
                            "Previous Results",
                            style: TextStyle(color: Colors.black),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).colorScheme.primary,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 12)),
                          onPressed: () {
                            Navigator.of(context).pushReplacementNamed(AppRoutes.homeScreen);
                          },
                          child: const Text("Back to Home"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultTile({
    required String title,
    required int value,
    required Color color,
    required String filter,
  }) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TestResultDetailScreen(
              testName: widget.testName,
              questions: widget.questions,
              answers: widget.answers,
              filter: filter,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black12),
        ),
        child: Row(
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            Text(
              "$value",
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold, color: color),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.arrow_forward_outlined),
          ],
        ),
      ),
    );
  }
}
//
// import 'dart:ui';
// import 'dart:convert'; // ✅ Needed for jsonEncode/jsonDecode
// import 'package:examgrid/routes.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:percent_indicator/percent_indicator.dart';
// import 'test_result_detail_screen.dart'; // ✅ Import detail screen
//
// class ResultScreen extends StatefulWidget {
//   final String testName;
//   final List<Map<String, dynamic>> questions;
//   final Map<int, String> answers;
//
//   const ResultScreen({
//     Key? key,
//     required this.testName,
//     required this.questions,
//     required this.answers,
//   }) : super(key: key);
//
//   @override
//   State<ResultScreen> createState() => _ResultScreenState();
// }
//
// class _ResultScreenState extends State<ResultScreen> {
//   final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
//
//   int correct = 0;
//   int incorrect = 0;
//   int unanswered = 0;
//   double percentage = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _calculateResults();
//   }
//
//   void _calculateResults() {
//     int c = 0, ic = 0, s = 0;
//     for (int i = 0; i < widget.questions.length; i++) {
//       final correctAnswer = widget.questions[i]["answer"];
//       final userAnswer = widget.answers[i];
//
//       if (userAnswer == null) {
//         s++;
//       } else if (userAnswer == correctAnswer) {
//         c++;
//       } else {
//         ic++;
//       }
//     }
//
//     setState(() {
//       correct = c;
//       incorrect = ic;
//       unanswered = s;
//       percentage = (c / widget.questions.length) * 100;
//     });
//
//     // ✅ Pass values to _saveResults
//     _saveResults(
//       testName: widget.testName,
//       correct: c,
//       incorrect: ic,
//       unanswered: s,
//       percentage: percentage,
//       questions: widget.questions.map((q) {
//         return {
//           ...q,
//           "userAnswer": widget.answers[widget.questions.indexOf(q)],
//         };
//       }).toList(),
//     );
//   }
//
//   Future<void> _saveResults() async {
//     final Map<String, dynamic> resultData = {
//       "testName": widget.testName,
//       "score": percentage.toStringAsFixed(1),
//       "correct": correct,
//       "incorrect": incorrect,
//       "unanswered": unanswered,
//       "date": DateTime.now().toIso8601String(),
//     };
//
//     // Fetch old history
//     String? existingData = await _secureStorage.read(key: "test_history");
//
//     List<Map<String, dynamic>> history = [];
//     if (existingData != null && existingData.isNotEmpty) {
//       history = List<Map<String, dynamic>>.from(jsonDecode(existingData));
//     }
//
//     // Add new result at the start
//     history.insert(0, resultData);
//
//     // Save back
//     await _secureStorage.write(
//       key: "test_history",
//       value: jsonEncode(history),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Theme.of(context).colorScheme.primary,
//       body: Column(
//         children: [
//           const SizedBox(height: 80),
//
//           // 📌 Title pill
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(30),
//               child: BackdropFilter(
//                 filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
//                 child: Container(
//                   padding:
//                   const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
//                   decoration: BoxDecoration(
//                     color: Colors.white.withOpacity(0.2),
//                     borderRadius: BorderRadius.circular(30),
//                     border: Border.all(
//                       color: Colors.white.withOpacity(0.3),
//                       width: 1,
//                     ),
//                   ),
//                   child: Text(
//                     widget.testName,
//                     style: const TextStyle(
//                       color: Colors.white,
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           // 📊 Circular Score
//           CircularPercentIndicator(
//             arcType: ArcType.HALF,
//             radius: 80.0,
//             lineWidth: 15.0,
//             animation: true,
//             percent: correct / widget.questions.length,
//             center: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Text(
//                   "${percentage.toStringAsFixed(0)}%",
//                   style: const TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 24,
//                       color: Colors.white),
//                 ),
//                 const SizedBox(height: 15),
//                 const Text(
//                   "Your Score",
//                   style: TextStyle(fontSize: 23, color: Colors.white),
//                 ),
//               ],
//             ),
//             circularStrokeCap: CircularStrokeCap.round,
//             progressColor: Colors.green,
//             backgroundColor: Colors.white,
//             arcBackgroundColor: Colors.white,
//           ),
//
//           const SizedBox(height: 20),
//
//           // 📌 Expandable bottom section
//           Expanded(
//             child: Container(
//               decoration: BoxDecoration(
//                 color: Theme.of(context).colorScheme.secondary,
//                 borderRadius: const BorderRadius.only(
//                   topLeft: Radius.circular(50),
//                   topRight: Radius.circular(50),
//                 ),
//               ),
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     const SizedBox(height: 20),
//                     _resultTile(
//                       title: "Correct Answers",
//                       value: correct,
//                       color: Colors.green,
//                       filter: "correct",
//                     ),
//                     _resultTile(
//                       title: "Wrong Answers",
//                       value: incorrect,
//                       color: Colors.red,
//                       filter: "incorrect",
//                     ),
//                     _resultTile(
//                       title: "Unanswered",
//                       value: unanswered,
//                       color: Colors.orange,
//                       filter: "unanswered",
//                     ),
//                     const SizedBox(height: 40),
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                       children: [
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 12)),
//                           onPressed: () {
//                             // Navigate to history screen
//                           },
//                           child: const Text(
//                             "Previous Results",
//                             style: TextStyle(color: Colors.black),
//                           ),
//                         ),
//                         ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                               backgroundColor:
//                               Theme.of(context).colorScheme.primary,
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 20, vertical: 12)),
//                           onPressed: () {
//                             Navigator.of(context)
//                                 .pushReplacementNamed(AppRoutes.homeScreen);
//                           },
//                           child: const Text("Back to Home"),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _resultTile({
//     required String title,
//     required int value,
//     required Color color,
//     required String filter,
//   }) {
//     return InkWell(
//       onTap: () {
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (_) => TestResultDetailScreen(
//               testName: widget.testName,
//               questions: widget.questions,
//               answers: widget.answers,
//               filter: filter,
//             ),
//           ),
//         );
//       },
//       child: Container(
//         margin: const EdgeInsets.symmetric(vertical: 6),
//         padding: const EdgeInsets.all(12),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(10),
//           border: Border.all(color: Colors.black12),
//         ),
//         child: Row(
//           children: [
//             Text(
//               title,
//               style:
//               const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//             ),
//             const Spacer(),
//             Text(
//               "$value",
//               style: TextStyle(
//                   fontSize: 16, fontWeight: FontWeight.bold, color: color),
//             ),
//             const SizedBox(width: 10),
//             const Icon(Icons.arrow_forward_outlined),
//           ],
//         ),
//       ),
//     );
//   }
//}