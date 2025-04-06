import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'investment_detail_page.dart';
import 'profile_page.dart';
import 'sign_in_page.dart';
import 'home_page.dart';

class BestInvestmentPage extends StatefulWidget {
  const BestInvestmentPage({super.key});

  @override
  _BestInvestmentPageState createState() => _BestInvestmentPageState();
}

class _BestInvestmentPageState extends State<BestInvestmentPage> {
  // Form state variables
  String? selectedGoal;
  String? selectedRisk;
  String? enteredAmount;
  String? specialInstructions;
  int? years;
  int? months;
  int? days;
  bool isLoading = false;
  List<Map<String, String>> recommendations = [];

  // Scaffold key for drawer control
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<String> goals = [
    "Wealth Growth",
    "Retirement",
    "Education",
    "Passive Income",
    "Real Estate",
    "Stock Market",
    "Crypto Investment",
  ];
  final List<String> riskLevels = ["Low", "Medium", "High"];

  Future<void> _getRecommendations() async {
    if (selectedGoal == null ||
        selectedRisk == null ||
        enteredAmount == null ||
        years == null ||
        months == null ||
        days == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all fields"),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          backgroundColor: Colors.blue[600],
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    String prompt =
        "Based on the following preferences: Goal - $selectedGoal, "
        "Risk Level - $selectedRisk, Time Horizon - ${years}Y ${months}M ${days}D, "
        "Investment Amount - $enteredAmount, suggest the top 3 investment options "
        "available in India. Focus on Indian investment schemes, mutual funds, "
        "stock market options, government-backed plans, and other India-specific "
        "opportunities. Format each suggestion as 'Title: Short description'. "
        "Remove any numbering, '*' symbols, or extra formatting.";

    String response = await GeminiAPIService.getResponse(prompt);

    setState(() {
      isLoading = false;
      recommendations =
          response.split('\n').where((line) => line.contains(':')).take(3).map((
            line,
          ) {
            List<String> parts = line.split(':');
            return {
              'title': parts[0].replaceAll('*', '').trim(),
              'description':
                  parts.length > 1 ? parts[1].replaceAll('*', '').trim() : '',
            };
          }).toList();
    });
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SignInPage()),
      );
    }
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            _buildHeaderSection(),
            const SizedBox(height: 24),

            // Form Section
            _buildFormSection(),

            // Results Section
            if (recommendations.isNotEmpty) _buildResultsSection(),
          ],
        ),
      ),
    );
  }

  // Rest of your existing widget methods remain unchanged...
  Widget _buildHeaderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Personalized Investment Recommendations",
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Tell us about your investment preferences, and we'll recommend "
          "the best options tailored for you.",
          style: GoogleFonts.roboto(
            fontSize: 16,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildFormSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.blue.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Investment Amount
            _buildTextField(
              "Investment Amount",
              FontAwesomeIcons.indianRupeeSign,
              (value) => setState(() => enteredAmount = value),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),

            // Time Horizon
            Text(
              "Time Horizon",
              style: GoogleFonts.roboto(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildSmallTextField(
                    "Years",
                    (value) => setState(() => years = int.tryParse(value)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallTextField(
                    "Months",
                    (value) => setState(() => months = int.tryParse(value)),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildSmallTextField(
                    "Days",
                    (value) => setState(() => days = int.tryParse(value)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Risk Level
            _buildDropdown(
              "Risk Level",
              riskLevels,
              Icons.assessment,
              (value) => setState(() => selectedRisk = value),
            ),
            const SizedBox(height: 16),

            // Investment Goal
            _buildDropdown(
              "Investment Goal",
              goals,
              Icons.flag,
              (value) => setState(() => selectedGoal = value),
            ),
            const SizedBox(height: 16),

            // Special Instructions
            _buildTextField(
              "Special Instructions (Optional)",
              FontAwesomeIcons.lightbulb,
              (value) => setState(() => specialInstructions = value),
              maxLines: 2,
            ),

            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _getRecommendations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                  shadowColor: Colors.blue.withOpacity(0.3),
                ),
                child:
                    isLoading
                        ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          ),
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.search, size: 20),
                            const SizedBox(width: 10),
                            Text(
                              "Get Recommendations",
                              style: GoogleFonts.roboto(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
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

  Widget _buildResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 30),
        Text(
          "Recommended Investment Options",
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.blue[900],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Based on your preferences, here are our top recommendations",
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 16),
        ...recommendations.map((rec) => _buildRecommendationCard(rec)).toList(),
      ],
    );
  }

  Widget _buildTextField(
    String label,
    IconData icon,
    Function(String) onChanged, {
    TextInputType? keyboardType,
    int? maxLines = 1,
  }) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        labelStyle: GoogleFonts.roboto(color: Colors.grey[600]),
      ),
      keyboardType: keyboardType,
      onChanged: onChanged,
      maxLines: maxLines,
      style: GoogleFonts.roboto(fontSize: 15),
    );
  }

  Widget _buildSmallTextField(String label, Function(String) onChanged) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 12,
        ),
        labelStyle: GoogleFonts.roboto(color: Colors.grey[600]),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
      style: GoogleFonts.roboto(fontSize: 14),
    );
  }

  Widget _buildDropdown(
    String label,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        labelStyle: GoogleFonts.roboto(color: Colors.grey[600]),
      ),
      items:
          items
              .map(
                (item) => DropdownMenuItem(
                  value: item,
                  child: Text(
                    item,
                    style: GoogleFonts.roboto(
                      fontSize: 15,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              )
              .toList(),
      onChanged: onChanged,
      style: GoogleFonts.roboto(fontSize: 15, color: Colors.grey[800]),
      dropdownColor: Colors.white,
      borderRadius: BorderRadius.circular(10),
      icon: Icon(Icons.arrow_drop_down, color: Colors.blue[600]),
      selectedItemBuilder: (BuildContext context) {
        return items.map<Widget>((String item) {
          return Text(
            item,
            style: GoogleFonts.roboto(fontSize: 15, color: Colors.grey[800]),
          );
        }).toList();
      },
    );
  }

  Widget _buildRecommendationCard(Map<String, String> recommendation) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 2,
      color: Colors.white,
      shadowColor: Colors.blue.withOpacity(0.1),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => InvestmentDetailPage(
                    title: recommendation['title'] ?? 'Investment Details',
                  ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.auto_graph,
                      color: Colors.blue[600],
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recommendation['title'] ?? '',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[900],
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          recommendation['description'] ?? '',
                          style: GoogleFonts.roboto(
                            fontSize: 14,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "View Details",
                    style: GoogleFonts.roboto(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.blue[700],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}