import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../services/gemini_api_service.dart';
import 'package:flutter/foundation.dart';

class AnalysisPage extends StatefulWidget {
  final File? file;
  final String fileName;
  final Uint8List? fileBytes;

  const AnalysisPage({
    super.key,
    this.file,
    this.fileBytes,
    required this.fileName,
  });

  @override
  State<AnalysisPage> createState() => _AnalysisPageState();
}

class _AnalysisPageState extends State<AnalysisPage> {
  String _analysisResult = '';
  String _extractedText = '';
  bool _isAnalyzing = true;
  String? _error;
  double _progress = 0;
  bool _showFullDocument = false;

  @override
  void initState() {
    super.initState();
    _analyzeDocument();
  }

  Future<void> _analyzeDocument() async {
    try {
      setState(() {
        _isAnalyzing = true;
        _progress = 0;
        _error = null;
      });

      // Step 1: Validate PDF
      setState(() => _progress = 0.1);
      Uint8List? bytes;
      if (kIsWeb) {
        if (widget.fileBytes == null) throw Exception('No file selected.');
        bytes = widget.fileBytes!;
      } else {
        if (widget.file == null) throw Exception('No file selected.');
        bytes = await widget.file!.readAsBytes();
      }
      await _validatePdf(bytes);

      // Step 2: Load and extract text with progress
      setState(() => _progress = 0.3);
      _extractedText = await _extractTextWithProgress(bytes);

      // Step 3: Analyze with AI
      setState(() => _progress = 0.7);
      final analysis = await _getAIAnalysis(_extractedText);

      setState(() {
        _analysisResult = analysis;
        _isAnalyzing = false;
        _progress = 1.0;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to analyze document: ${e.toString()}';
        _isAnalyzing = false;
      });
    }
  }

  Widget _buildResultsView() {
    return Column(
      children: [
        // Document Info and Toggle
        Card(
          margin: const EdgeInsets.all(16),
          elevation: 2,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(Icons.description, size: 40, color: Colors.blue),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fileName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            kIsWeb
                                ? widget.fileBytes != null
                                    ? '${(widget.fileBytes!.lengthInBytes / 1024).toStringAsFixed(1)} KB'
                                    : 'Unknown size'
                                : widget.file != null
                                ? '${(widget.file!.lengthSync() / 1024).toStringAsFixed(1)} KB'
                                : 'Unknown size',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Show extracted document text:'),
                    const SizedBox(width: 8),
                    Switch(
                      value: _showFullDocument,
                      onChanged: (value) {
                        setState(() {
                          _showFullDocument = value;
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),

        // Main Content
        Expanded(
          child:
              _showFullDocument
                  ? _buildDocumentTextView()
                  : _buildAnalysisView(),
        ),
      ],
    );
  }

  Widget _buildDocumentTextView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          _extractedText.isNotEmpty ? _extractedText : 'No text extracted',
          style: const TextStyle(fontSize: 14, height: 1.5),
        ),
      ),
    );
  }

  Widget _buildAnalysisView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Document Analysis Summary',
            style: GoogleFonts.roboto(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Key insights from your document',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          if (_analysisResult.isEmpty)
            const Center(child: Text('No analysis results available'))
          else
            ..._buildEnhancedAnalysisSections(),

          const SizedBox(height: 24),
          _buildActionButtons(),
        ],
      ),
    );
  }

  Future<void> _validatePdf(Uint8List bytes) async {
    // final bytes = kIsWeb ? widget.fileBytes! : await widget.file!.readAsBytes();
    if (bytes.lengthInBytes > 10 * 1024 * 1024) {
      throw Exception('PDF is too large (max 10MB)');
    }
    if (!String.fromCharCodes(bytes.sublist(0, 4)).contains('%PDF')) {
      throw Exception('Not a valid PDF file');
    }
  }

  Future<String> _extractTextWithProgress(Uint8List fileBytes) async {
    try {
      final bytes = fileBytes;
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      final PdfTextExtractor extractor = PdfTextExtractor(document);
      final StringBuffer fullText = StringBuffer();

      for (int i = 1; i <= document.pages.count; i++) {
        setState(() => _progress = 0.3 + (0.4 * i / document.pages.count));
        try {
          String pageText = extractor.extractText(startPageIndex: i - 1);
          pageText = _cleanPdfText(pageText);
          fullText.write(pageText);

          if (i < document.pages.count) {
            fullText.write('\n\n[PAGE BREAK]\n\n');
          }
        } catch (e) {
          debugPrint('Error extracting page $i: $e');
          fullText.write('\n\n[Error extracting page $i]\n\n');
        }
      }

      document.dispose();
      return fullText.toString();
    } catch (e) {
      debugPrint('Error extracting text: $e');
      return '';
    }
  }

  String _cleanPdfText(String text) {
    // Improved text cleaning
    text = text.replaceAllMapped(RegExp(r'(\w+)-\s*\n\s*(\w+)'), (match) {
      return '${match.group(1)}${match.group(2)}';
    });
    text = text.replaceAll(RegExp(r'(?<!\n)\n(?!\n|\s*\n)'), ' ');
    text = text.replaceAll(RegExp(r'\n\s*\n'), '\n\n');
    text = text.replaceAll(RegExp(r'[ \t]{2,}'), ' ');
    text = text.replaceAll(RegExp(r'^ +| +$', multiLine: true), '');
    return text;
  }

  Future<String> _getAIAnalysis(String text) async {
    final truncatedText =
        text.length > 15000
            ? '${text.substring(0, 15000)}... [document truncated]'
            : text;

    final prompt = """
    **Document Analysis Request**
    
    Please provide a comprehensive analysis of this document with the following structure:
    
    ### 1. Document Identification
    - **Type**: [Identify document type - contract, agreement, terms of service, etc.]
    - **Parties**: [Identify the parties involved]
    - **Effective Date**: [If mentioned]
    - **Governing Law**: [Jurisdiction/law specified]
    
    ### 2. Executive Summary (1-2 paragraphs)
    - Concise overview of the document's purpose and key implications
    
    ### 3. Key Provisions (Bullet Points)
    - **Important Rights**: [User's key rights]
    - **Major Obligations**: [User's main responsibilities]
    - **Critical Restrictions**: [Important limitations]
    - **Duration/Term**: [How long it lasts]
    - **Termination**: [Conditions for ending agreement]
    
    ### 4. Risk Assessment
    - **Potential Risks**: [3-5 main risks with severity (High/Medium/Low)]
    - **Hidden Clauses**: [Any non-obvious but important terms]
    - **Auto-Renewals**: [If automatic renewal exists]
    - **Penalties/Fees**: [Any financial obligations]
    
    ### 5. Actionable Advice
    - **Recommended Actions**: [What user should do next]
    - **Questions to Ask**: [Key questions for clarification]
    - **Review Needed**: [Whether legal review is recommended]
    
    ### 6. Plain Language Explanation
    - Rewrite 3 most complex clauses in simple terms
    
    **Analysis Guidelines:**
    1. Be objective and factual
    2. Highlight concerning terms in **bold**
    3. Use simple language (8th grade level)
    4. Focus on practical implications
    5. Include specific clause references when possible
    
    **Document Text:**
    $truncatedText
    """;

    return await GeminiAPIService.getResponse(prompt);
  }

  List<Widget> _buildEnhancedAnalysisSections() {
    try {
      final sections = <Widget>[];
      final blocks = _analysisResult
          .split('### ')
          .skip(1); // Skip empty first element

      for (final block in blocks) {
        if (block.trim().isEmpty) continue;

        final headerEnd = block.indexOf('\n');
        final title =
            headerEnd > 0 ? block.substring(0, headerEnd).trim() : block.trim();
        final content = headerEnd > 0 ? block.substring(headerEnd).trim() : '';

        if (content.isNotEmpty) {
          sections.add(_buildEnhancedSection(title, content));
        }
      }

      return sections;
    } catch (e) {
      debugPrint('Error parsing analysis: $e');
      return [
        const Text('Could not parse analysis results'),
        const SizedBox(height: 16),
        Text(_analysisResult),
      ];
    }
  }

  Widget _buildEnhancedSection(String title, String content) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _getSectionIcon(title),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: GoogleFonts.roboto(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ..._parseContent(content),
          ],
        ),
      ),
    );
  }

  List<Widget> _parseContent(String content) {
    final widgets = <Widget>[];
    final lines = content.split('\n');

    for (final line in lines) {
      if (line.trim().isEmpty) continue;

      if (line.trim().startsWith('- **') || line.trim().startsWith('* **')) {
        // Bold subheading
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 4),
            child: Text(
              line
                  .replaceAll('- **', '')
                  .replaceAll('* **', '')
                  .replaceAll('**', ''),
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
        );
      } else if (line.trim().startsWith('- ') || line.trim().startsWith('* ')) {
        // Regular bullet point
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              '• ${line.substring(2)}',
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        );
      } else if (line.trim().contains('**')) {
        // Bold text within paragraph
        final parts = line.split('**');
        widgets.add(
          RichText(
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black,
              ),
              children: List.generate(parts.length, (index) {
                return TextSpan(
                  text: parts[index],
                  style:
                      index % 2 == 1
                          ? const TextStyle(fontWeight: FontWeight.bold)
                          : null,
                );
              }),
            ),
          ),
        );
      } else {
        // Regular paragraph
        widgets.add(
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              line,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ),
        );
      }
    }

    return widgets;
  }

  Widget _getSectionIcon(String title) {
    if (title.contains('Identification')) {
      return const Icon(Icons.assignment, color: Colors.blue);
    } else if (title.contains('Summary')) {
      return const Icon(Icons.summarize, color: Colors.green);
    } else if (title.contains('Provisions') || title.contains('Terms')) {
      return const Icon(Icons.list_alt, color: Colors.orange);
    } else if (title.contains('Risk') || title.contains('Warning')) {
      return const Icon(Icons.warning, color: Colors.red);
    } else if (title.contains('Advice') || title.contains('Action')) {
      return const Icon(Icons.lightbulb, color: Colors.amber);
    } else {
      return const Icon(Icons.info, color: Colors.blue);
    }
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            icon: const Icon(Icons.refresh),
            label: const Text('Re-analyze'),
            onPressed: _analyzeDocument,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.share),
            label: const Text('Share Summary'),
            onPressed: () {
              // Implement share functionality
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Document Analysis', style: GoogleFonts.roboto()),
        actions: [
          if (_isAnalyzing)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Text(
                  '${(_progress * 100).toStringAsFixed(0)}%',
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Analysis Help'),
                      content: const Text(
                        'This analysis is generated by AI and should be used as guidance only. '
                        'For legal documents, consult a qualified professional.',
                      ),
                      actions: [
                        TextButton(
                          child: const Text('OK'),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
      body:
          _isAnalyzing
              ? _buildProgressView()
              : _error != null
              ? _buildErrorView()
              : _buildResultsView(),
    );
  }

  Widget _buildProgressView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.blue[400] ?? Colors.blue,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Analyzing document...',
            style: GoogleFonts.roboto(fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            'This may take a few moments',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 24),
            Text(
              'Analysis Failed',
              style: GoogleFonts.roboto(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _error ?? 'Unknown error occurred',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _analyzeDocument,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
