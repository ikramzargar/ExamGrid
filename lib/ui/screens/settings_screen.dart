import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
 final String? firstName;
 final String? lastName;
 final String email;
 final String phoneNo;
  const SettingsScreen({super.key, required this.firstName, required this.lastName,required this.email, required this.phoneNo});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {


  String appVersion = "";

  @override
  void initState() {
    super.initState();
    _fetchAppVersion();
  }


  Future<void> _fetchAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = "${info.version}";
    });
  }

  void _signOut() async {
    await FirebaseAuth.instance.signOut();
    if (!mounted) return;
    Navigator.pushReplacementNamed(
        context, '/login'); // Change to your login route
  }

  @override
  Widget build(BuildContext context) {
    var firstName = widget.firstName;
    var email = widget.email;
    var phoneNumber = widget.phoneNo;
    var lastName = widget.lastName;
    final displayName = (firstName != null && lastName != null)
        ? "$firstName $lastName"
        : "User";

    return Scaffold(
      appBar: AppBar(
        title: Center(child: const Text("Settings")),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SizedBox(
            height: 10,
          ),
          CircleAvatar(
            radius: 70,
            backgroundColor: Colors.transparent,
            child: ClipOval(
              child: Image.asset(
                'images/avatar.png',
                fit: BoxFit.cover,
                width: 120,
                height: 120,
              ),
            ),
          ),
          // Profile Info
          // ListTile(
          //   leading: const CircleAvatar(child: Icon(Icons.person)),
          //   title: Text("Hi, $displayName"),
          //   subtitle: Text(user?.email ?? ""),
          //   trailing: Text(phoneNumber ?? ""),
          // ),
          SizedBox(
            height: 20,
          ),
          Text(
            'Hi, $displayName',
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.black45),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Email id: $email',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Phone No.: +91-$phoneNumber',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
          ),
          SizedBox(
            height: 20,
          ),
          const Divider(),

          // Privacy Policy
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text("Privacy Policy"),
            onTap: () async {
              final Uri url = Uri.parse("https://www.examgrid.space/privacy-policy");

              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              throw Exception("Could not launch $url");
              }
            },
          ),

          // Terms & Conditions
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text("Terms & Conditions"),
            onTap: () async {
              final Uri url = Uri.parse("https://www.examgrid.space/terms-conditions");

              if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
              throw Exception("Could not launch $url");
              }
            },
          ),

          ListTile(
            leading: const Icon(Icons.support_agent),
            title: const Text("Help and support"),
            onTap: () async {
              final Uri emailLaunchUri = Uri(
                scheme: 'mailto',
                path: 'ikramulhaqzargar@gmail.com',
                query: Uri.encodeFull('subject=Support Request Examgrid'),
              );

              if (!await launchUrl(emailLaunchUri)) {
                throw Exception("Could not launch $emailLaunchUri");
              }
            },
          ),

          // Sign Out
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text("Sign Out"),
            onTap: _signOut,
          ),

          const Divider(),
          SizedBox(
            height: 20,
          ),
          // App Version
          Center(
            child: Text(
              "App version: $appVersion",
              style: const TextStyle(color: Colors.grey),
            ),
          ),

          Center(
              child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Developed by",
                style: const TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () async {
                  final Uri url = Uri.parse("https://ikram-zargar.web.app/");

                  if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
                    throw Exception("Could not launch $url");
                  }
                },
                child: Row(
                  children: [
                    Icon(Icons.link),
                    Text(
                      'Ikram Zargar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              )
            ],
          )),
        ],
      ),
    );
  }
}
