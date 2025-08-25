import 'package:cloud_firestore/cloud_firestore.dart';


class TestRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchTestQuestions(String testId) async {
    final snapshot = await _firestore
        .collection("Tests")
        .doc(testId)
        .collection("questions")
      //  .orderBy("question-no.")
        .get();
    print(snapshot.docs.map((doc) => doc.data()).toList());

    return snapshot.docs.map((doc) => doc.data()).toList();
  }
}