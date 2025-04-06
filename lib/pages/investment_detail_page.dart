import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/gemini_api_service.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/custom_drawer.dart';
import 'home_page.dart';
import 'profile_page.dart';
import 'sign_in_page.dart';

class InvestmentDetailPage extends StatefulWidget {
  final String title;

  const InvestmentDetailPage({super.key, required this.title});

  @override
  _InvestmentDetailPageState createState() => _InvestmentDetailPageState();
}

class _InvestmentDetailPageState extends State<InvestmentDetailPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  Map<String, String> investmentDetails = {};
  bool isLoading = true;
  String currentPrice = 'Loading...';
  String oneYearReturn = 'Loading...';

  @override
  void initState() {
    super.initState();
    _fetchInvestmentDetails();
    _fetchMarketData();
  }

  Future<void> _fetchMarketData() async {
    // Simulate API call for market data
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      currentPrice = '₹---'; // Placeholder for real data
      oneYearReturn = '--%'; // Placeholder for real data
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

  Future<void> _fetchInvestmentDetails() async {
    String prompt = """
    Provide a detailed yet concise explanation of '${widget.title}' as an investment option in India, 
    strictly following this exact structure (include all sections):

    **Overview** 
    [Brief 2-3 line introduction about what this investment is]

    **Key Features**
    [Bullet points of 3-5 most important characteristics]

    **How It Works** 
    [Step-by-step explanation of the investment mechanism in simple terms]

    **Why Consider This?** 
    [3-5 compelling reasons to invest in this option with concrete benefits]

    **Potential Returns** 
    [Realistic return expectations with typical percentage ranges]

    **Risk Factors** 
    [Clear explanation of risks with probability/impact assessment]

    **Who Should Invest?** 
    [Ideal investor profile based on goals, risk appetite, timeline]

    **How to Get Started** 
    [Step-by-step guide to begin investing, including:
     - Minimum investment amount
     - Popular platforms/brokers in India
     - Required documents
     - Account setup process]

    **Tax Implications** 
    [How returns are taxed in India (short-term/long-term capital gains, exemptions)]

    **Pros & Cons** 
    [Balanced comparison table with 3-5 items each]

    **Alternatives to Consider** 
    [2-3 comparable investment options with brief comparisons]

    Formatting Rules:
    - Use **bold** only for section headers
    - No numbering or bullet characters
    - Keep language simple (8th grade level)
    - Focus specifically on Indian context
    - Include real examples where possible
    - Maintain neutral, factual tone
    """;

    String response = await GeminiAPIService.getResponse(prompt);
    setState(() {
      investmentDetails = _processAIResponse(response);
      isLoading = false;
    });
  }

  Widget _buildMarketSnapshot() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Market Snapshot',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricTile(
                'Current Value',
                currentPrice,
                Icons.attach_money,
              ),
              _buildMetricTile('1Y Return', oneYearReturn, Icons.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 30, color: Colors.blue[700]),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.roboto(fontSize: 14, color: Colors.grey[600]),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.blue[800],
          ),
        ),
      ],
    );
  }

  Widget _buildKeyMetrics() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'At a Glance',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.blue[800],
            ),
          ),
          const SizedBox(height: 16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildMetricChip('Liquidity', 'Medium'),
              _buildMetricChip('Risk Level', 'Moderate'),
              _buildMetricChip('Min Investment', '₹---'),
              _buildMetricChip('Lock-in Period', '--'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricChip(String label, String value) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        minWidth: 100,
        maxWidth: 150,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blue[100]!),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: Text(
                  '$label: ',
                  style: GoogleFonts.roboto(
                    fontSize: 14,
                    color: Colors.grey[700],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Flexible(
                child: Text(
                  value,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue[800],
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
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
          Navigator.pop(context);
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
        },
      ),
      body: Container(
        color: Colors.grey[50],
        padding: const EdgeInsets.all(16),
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text(
                      "Analyzing investment details...",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(12),
                        image: const DecorationImage(
                          image: AssetImage(
                            'assets/images/explore_illustration.png',
                          ),
                          fit: BoxFit.cover,
                          opacity: 0.1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue[700],
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.auto_graph,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.title,
                                  style: GoogleFonts.poppins(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.blue[900],
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Investment Analysis',
                                  style: GoogleFonts.roboto(
                                    fontSize: 14,
                                    color: Colors.blue[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildMarketSnapshot(),
                    _buildKeyMetrics(),

                    if (investmentDetails.isNotEmpty)
                      ExpansionTile(
                        initiallyExpanded: true,
                        title: Text(
                          'Detailed Analysis',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.blue[800],
                          ),
                        ),
                        children: [
                          ...investmentDetails.entries.map(
                            (entry) => _buildSection(entry.key, entry.value),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
      ),
    );
  }
}

Map<String, String> _processAIResponse(String response) {
  final Map<String, String> parsedSections = {};
  final List<String> lines = response.split('\n');

  String currentSection = '';
  final buffer = StringBuffer();
  bool isFirstSection = true;

  const expectedSections = [
    'Overview',
    'Key Features',
    'How It Works',
    'Why Consider This',
    'Potential Returns',
    'Risk Factors',
    'Who Should Invest',
    'How to Get Started',
    'Tax Implications',
    'Pros & Cons',
    'Alternatives to Consider',
  ];

  for (final line in lines) {
    final trimmedLine = line.trim();

    final isBoldHeader =
        trimmedLine.startsWith('**') && trimmedLine.endsWith('**');
    final isColonHeader =
        trimmedLine.endsWith(':') &&
            expectedSections.any(
              (section) =>
                  trimmedLine.toLowerCase().contains(section.toLowerCase()),
            );

    if (isBoldHeader || isColonHeader) {
      if (currentSection.isNotEmpty) {
        parsedSections[currentSection] = _cleanContent(buffer.toString());
        buffer.clear();
      }

      currentSection =
          trimmedLine.replaceAll('**', '').replaceAll(':', '').trim();

      for (final section in expectedSections) {
        if (currentSection.toLowerCase().contains(section.toLowerCase())) {
          currentSection = section;
          break;
        }
      }

      isFirstSection = false;
    } else if (trimmedLine.isEmpty && buffer.isEmpty && !isFirstSection) {
      continue;
    } else if (currentSection.isNotEmpty &&
        !trimmedLine.endsWith(':') &&
        !(trimmedLine.startsWith('**') && trimmedLine.endsWith('**'))) {
      buffer.writeln(trimmedLine);
    }
  }

  if (currentSection.isNotEmpty) {
    parsedSections[currentSection] = _cleanContent(buffer.toString());
  }

  for (final section in expectedSections) {
    parsedSections.putIfAbsent(
      section,
      () => 'Details not provided in response',
    );
  }

  _cleanSpecialSections(parsedSections);

  return parsedSections;
}

String _cleanContent(String content) {
  return content
      .replaceAll(RegExp(r'^\d+[\.\)]'), '')
      .replaceAll(RegExp(r'[\*\-#]'), '')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

void _cleanSpecialSections(Map<String, String> sections) {
  const bulletSections = ['Key Features', 'Pros & Cons'];
  for (final section in bulletSections) {
    if (sections.containsKey(section)) {
      final content = sections[section]!;
      if (content.contains('- ') || content.contains('* ')) {
        sections[section] = content
            .split('\n')
            .where((line) => line.trim().isNotEmpty)
            .map((line) => line.replaceAll(RegExp(r'^[\-\*]\s*'), '• '))
            .join('\n');
      }
    }
  }

  if (sections.containsKey('How to Get Started')) {
    final content = sections['How to Get Started']!;
    if (content.contains('1)') || content.contains('Step')) {
      sections['How to Get Started'] = content
          .split('\n')
          .where((line) => line.trim().isNotEmpty)
          .map((line) => line.replaceAll(RegExp(r'^\d+[\)\.]'), '').trim())
          .map((line) => '• ${line.trim()}')
          .join('\n');
    }
  }
}

Widget _buildSection(String title, String content) {
  return Container(
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 2,
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ExpansionTile(
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getSectionIcon(title),
              size: 18,
              color: Colors.blue[700],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
        ],
      ),
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Text(
            content,
            style: GoogleFonts.roboto(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.6,
            ),
          ),
        ),
      ],
    ),
  );
}

IconData _getSectionIcon(String title) {
  switch (title.toLowerCase()) {
    case 'overview':
      return Icons.info_outline;
    case 'how it works':
      return Icons.workspaces_outline;
    case 'potential returns':
      return Icons.trending_up;
    case 'who should invest':
      return Icons.people_outline;
    case 'how to get started':
      return Icons.list_alt;
    case 'risk factors':
      return Icons.warning_amber_outlined;
    case 'tax implications':
      return Icons.receipt_outlined;
    case 'pros & cons':
      return Icons.compare_outlined;
    default:
      return Icons.article_outlined;
  }
}