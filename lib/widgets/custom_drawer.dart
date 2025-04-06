import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CustomDrawer extends StatelessWidget {
  final VoidCallback onProfileTap;
  final VoidCallback onLogoutTap;
  final VoidCallback onHomeTap; // New callback for home navigation
  final Function(int) onNavigationTap;

  const CustomDrawer({
    super.key,
    required this.onProfileTap,
    required this.onLogoutTap,
    required this.onHomeTap, // Added parameter
    required this.onNavigationTap,
  });

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Drawer(
        child: Column(
          children: [
            Container(
              color: Colors.blue,
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  user?.photoURL != null
                      ? CircleAvatar(
                          radius: 40, 
                          backgroundImage: NetworkImage(user!.photoURL!),
                        )
                      : const Icon(
                          Icons.account_circle, 
                          size: 80, 
                          color: Colors.white,
                        ),
                  const SizedBox(height: 10),
                  Text(
                    user?.displayName ?? "User",
                    style: const TextStyle(
                      fontSize: 18, 
                      color: Colors.white, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    user?.email ?? "", 
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Home"),
                    onTap: () {
                      Navigator.pop(context);
                      onHomeTap(); // Call the home tap callback
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: const Text("Profile"),
                    onTap: () {
                      Navigator.pop(context);
                      onProfileTap();
                    },
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text(
                      "Logout", 
                      style: TextStyle(color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      onLogoutTap();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}