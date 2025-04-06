import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'home_page.dart';
import 'sign_in_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final User? user = FirebaseAuth.instance.currentUser;

  final List<Map<String, String>> languages = [
    {"name": "English", "code": "en"},
    {"name": "हिन्दी", "code": "hi"},
    {"name": "বাংলা", "code": "bn"},
    {"name": "తెలుగు", "code": "te"},
    {"name": "मराठी", "code": "mr"},
    {"name": "தமிழ்", "code": "ta"},
    {"name": "ગુજરાતી", "code": "gu"},
    {"name": "ಕನ್ನಡ", "code": "kn"},
    {"name": "മലയാളം", "code": "ml"},
  ];

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
  }

  void _changeLanguage(String langCode) async {
    context.setLocale(Locale(langCode));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selected_language', langCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: CustomAppBar(
        scaffoldKey: _scaffoldKey,
        onProfilePressed: () => _scaffoldKey.currentState?.openEndDrawer(),
      ),
      endDrawer: CustomDrawer(
        onHomeTap: () {
          Navigator.pop(context); // Close the drawer first
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HomePage()),
          );
        },
        onProfileTap: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfilePage()),
          );
        },
        onLogoutTap: _logout,
        onNavigationTap: (index) {
          Navigator.pop(context);
          // Handle other navigation options if needed
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Profile Header
            CircleAvatar(
              radius: 60,
              backgroundImage:
                  user?.photoURL != null ? NetworkImage(user!.photoURL!) : null,
              child:
                  user?.photoURL == null
                      ? const Icon(Icons.person, size: 60)
                      : null,
            ),
            const SizedBox(height: 20),

            // User Info
            Text(
              user?.displayName ?? 'Guest User',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              user?.email ?? 'No email provided',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
            const SizedBox(height: 40),

            // Account Settings Card
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildListTile(
                      icon: Icons.edit,
                      title: 'Edit Profile',
                      onTap: () {}, // Add edit functionality
                    ),
                    const Divider(),
                    _buildListTile(
                      icon: Icons.security,
                      title: 'Privacy Settings',
                      onTap: () {},
                    ),
                    const Divider(),
                    _buildListTile(
                      icon: Icons.help,
                      title: 'Help & Support',
                      onTap: () {},
                    ),
                    const Divider(),
                    // Language Selection
                    ListTile(
                      leading: const Icon(Icons.language, color: Colors.blue),
                      title: const Text("Select Language"),
                      trailing: DropdownButton<String>(
                        value: context.locale.languageCode,
                        items:
                            languages.map((lang) {
                              return DropdownMenuItem(
                                value: lang["code"],
                                child: Text(lang["name"]!),
                              );
                            }).toList(),
                        onChanged: (String? newLang) {
                          if (newLang != null) {
                            _changeLanguage(newLang);
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.blue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}
