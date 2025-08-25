import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:examgrid/ui/screens/dashboard.dart';
import 'package:examgrid/ui/screens/settings_screen.dart';
import 'package:examgrid/ui/screens/test/test_history.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    _fetchUserDetails();
    super.initState();
  }

  final User? user = FirebaseAuth.instance.currentUser;

  String? firstName;
  String? lastName;
  String? phoneNumber;
  String? email;

  Future<void> _fetchUserDetails() async {
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get();

    if (snapshot.exists) {
      final data = snapshot.data()!;
      setState(() {
        firstName = data['firstName'];
        lastName = data['lastName'];
        email = data['email'];
        phoneNumber = data['phone'];
      });
    }
  }

  int _selectedIndex = 0;

  // Two simple placeholder pages

  void _onItemTapped(int idx) => setState(() => _selectedIndex = idx);

  @override
  Widget build(BuildContext context) {
    var pages = <Widget>[
      Dashboard(),
      HistoryScreen(),
      SettingsScreen(firstName: firstName ?? "",
        lastName: lastName ?? "",
        phoneNo: phoneNumber ?? "",
        email: email ?? "",),
    ];
    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home),    label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history),    label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person),  label: 'Account'),
        ],
      ),
    );
  }
}