import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/gemini_api_service.dart';

class AIPage extends StatefulWidget {
  const AIPage({super.key});

  @override
  _AIPageState createState() => _AIPageState();
}

class _AIPageState extends State<AIPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isThinking = false;

  void _sendMessage() async {
    if (_controller.text.isEmpty || _isThinking) return;

    String userQuery = _controller.text;
    _controller.clear();

    setState(() {
      _messages.add({"role": "user", "text": userQuery});
      _isThinking = true;
    });

    // Modified prompt to guide responses toward finance
    String financePrompt = "The user asked: '$userQuery'. "
        "Provide a helpful response that connects this to personal finance or investing concepts "
        "in the Indian market when possible. Explain in simple terms using examples with ₹ currency. "
        "If completely unrelated, give a short polite response and suggest a finance topic to discuss. "
        "Keep explanations under 100 words for clarity.";

    String response = await GeminiAPIService.getResponse(financePrompt);

    if (mounted) {
      setState(() {
        _messages.add({"role": "ai", "text": response});
        _isThinking = false;
      });

      Future.delayed(const Duration(milliseconds: 300), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            'Finance Guide',
            style: GoogleFonts.inter(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            // Welcome message
            if (_messages.isEmpty)
              Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 0,
                  color: Colors.blue[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      "Hi! I can help with financial questions. "
                      "Ask me anything and I'll try to relate it to smart money management",
                      style: GoogleFonts.inter(
                        fontSize: 15,
                        color: Colors.blue[800],
                      ),
                    ),
                  ),
                ),
              ),

            // Chat messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isUser = message["role"] == "user";
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
                      children: [
                        if (!isUser)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue[50],
                              child: Icon(Icons.auto_awesome, size: 18, color: Colors.blue[700]),
                            ),
                          ),
                        Flexible(
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width * 0.8,
                            ),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isUser ? Colors.blue[700] : Colors.grey[100],
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(12),
                                topRight: const Radius.circular(12),
                                bottomLeft: Radius.circular(isUser ? 12 : 4),
                                bottomRight: Radius.circular(isUser ? 4 : 12),
                              ),
                            ),
                            child: Text(
                              message["text"]!,
                              style: GoogleFonts.inter(
                                fontSize: 15,
                                color: isUser ? Colors.white : Colors.black87,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ),
                        if (isUser)
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            child: const CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.blue,
                              child: Icon(Icons.person, size: 18, color: Colors.white),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Loading indicator
            if (_isThinking)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Finding financial insights...",
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

            // Input area
            Container(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              style: GoogleFonts.inter(fontSize: 15),
                              decoration: InputDecoration(
                                hintText: "Ask me anything...",
                                hintStyle: GoogleFonts.inter(
                                  color: Colors.grey[500],
                                ),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                              ),
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.send, color: Colors.blue[700]),
                            onPressed: _sendMessage,
                          ),
                        ],
                      ),
                    ),
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