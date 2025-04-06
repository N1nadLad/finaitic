import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import '../pages/ai_page.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final GlobalKey<ScaffoldState> scaffoldKey;
  final VoidCallback? onProfilePressed;

  const CustomAppBar({
    super.key, 
    required this.scaffoldKey,
    this.onProfilePressed,
  });

  void _showChatbot(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: const AIPage(),
        );
      },
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    );
  }

  @override
 Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0.5,
      title: Row(
        children: [
          // Using the 500x500px logo with proper sizing
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              image: DecorationImage(
                image: AssetImage('assets/images/Fin_app_icon.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            "Finaitic",
            style: GoogleFonts.roboto(
              fontSize: 22, 
              fontWeight: FontWeight.bold, 
              color: Colors.black
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.chat_bubble_outline, size: 28, color: Colors.black),
          onPressed: () => _showChatbot(context),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: user?.photoURL != null
              ? CircleAvatar(
                  radius: 20, 
                  backgroundImage: NetworkImage(user!.photoURL!))
              : const Icon(Icons.account_circle, size: 30, color: Colors.black),
          onPressed: onProfilePressed ?? () => scaffoldKey.currentState?.openEndDrawer(),
        ),
        const SizedBox(width: 12),
      ],
    );
}

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}