import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgrid/ui/screens/test/test_screen.dart';
import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Column(
        children: [
          Container(
            height: 100,
            child: const Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Dashboard',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.bold),
                )),
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius:const BorderRadius.only(
                      topRight: Radius.circular(20),
                      topLeft: Radius.circular(20))),
              child: Column(
                children: [
                  SizedBox(height: 15,),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16), // roundness
                    child: Image.asset(
                      "images/dash.png",
                      fit: BoxFit.cover,
                      height: MediaQuery.of(context).size.height * 0.23,// ensures it fills nicely
                    ),
                  ),

                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance.collection("Tests").snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator(color: Colors.white));
                        }

                        if (snapshot.hasError) {
                          return const Center(child: Text("Error fetching tests"));
                        }

                        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                          return const Center(child: Text("No tests available"));
                        }

                        final tests = snapshot.data!.docs;

                        return ListView.builder(

                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                          itemCount: tests.length,
                          itemBuilder: (context, index) {
                            final test = tests[index];
                            final testId = test.id;
                            final testName = test['name'] ?? 'Untitled Test';
                            final isFree = test['isPaid'];

                            return Card(
                                color: Colors.white,
                                child: GestureDetector(
                                  onTap: (){
                                    Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => TestScreen(
                                        testId: testId,
                                        testName: testName,
                                      ),
                                    ),);
                                  },
                                  child: ListTile(
                                    //  contentPadding: EdgeInsets.all(10),
                                    // tileColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12), // Rounded corners
                                      side: BorderSide(
                                          color: Theme.of(context).colorScheme.primary,
                                          width: 1), // Border
                                    ),
                                    title: Text(
                                      testName,
                                      style: const TextStyle(color: Colors.black),
                                    ),
                                    subtitle: Padding(
                                      padding: const EdgeInsets.only(top: 10.0),
                                      child: Row(
                                        children: [
                                          Text('120 Questions'),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text('120 Minutes'),
                                          SizedBox(
                                            width: 10,
                                          ),
                                          Text(isFree ? "Paid" : "Free")
                                        ],
                                      ),
                                    ),
                                    trailing: Icon(Icons.edit_note_outlined,size: 40,),
                                   
                                  ),
                                ));
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
