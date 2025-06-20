import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wtms/myconfig.dart';
import 'package:wtms/model/submission.dart';

class HistoryScreen extends StatefulWidget {
  final int workerId;
  const HistoryScreen({super.key, required this.workerId});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<Submission> submissions = [];
  bool isLoading = true;
  String? errorMessage;
  List<bool> isExpandedList = [];

  @override
  void initState() {
    super.initState();
    fetchSubmissions();
  }

  Future<void> fetchSubmissions() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/wtms/php/get_submissions.php"),
        body: {'worker_id': widget.workerId.toString()},
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          final fetchedSubmissions = (responseData['data'] as List)
              .map((json) => Submission.fromJson(json))
              .toList();
          setState(() {
            submissions = fetchedSubmissions;
            isExpandedList = List.filled(submissions.length, false);
            isLoading = false;
          });
        } else {
          throw Exception(responseData['message'] ?? 'Unknown server error');
        }
      } else {
        throw Exception('Failed to load submissions. Status code: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        isLoading = false;
        errorMessage = 'Request timed out. Please check your connection.';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0ECFF), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Text(
                            errorMessage!,
                            style: const TextStyle(color: Colors.red, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchSubmissions,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  )
                : submissions.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text("No submission history available", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: fetchSubmissions,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: submissions.length,
                          itemBuilder: (context, index) {
                            final submission = submissions[index];
                            final isExpanded = isExpandedList[index];
                            final isLongText = submission.submissionText.length > 100;
                            final previewText = isLongText
                                ? '${submission.submissionText.substring(0, 100)}...'
                                : submission.submissionText;

                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                              elevation: 3,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.9),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.assignment, color: Colors.indigo),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            submission.title,
                                            style: const TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                                        const SizedBox(width: 4),
                                        Text(
                                          submission.submissionDate,
                                          style: const TextStyle(fontSize: 14, color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: const [
                                        Icon(Icons.text_snippet, size: 16, color: Colors.deepPurple),
                                        SizedBox(width: 6),
                                        Text(
                                          "Submission Preview:",
                                          style: TextStyle(fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      isExpanded ? submission.submissionText : previewText,
                                      style: const TextStyle(fontSize: 15),
                                    ),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton.icon(
                                        onPressed: isLongText
                                            ? () {
                                                setState(() {
                                                  isExpandedList[index] = !isExpanded;
                                                });
                                              }
                                            : null,
                                        icon: Icon(
                                          isExpanded
                                              ? Icons.expand_less
                                              : Icons.expand_more,
                                          color: isLongText
                                              ? (isExpanded ? Colors.red : Colors.indigo)
                                              : Colors.grey,
                                        ),
                                        label: Text(
                                          isLongText
                                              ? (isExpanded ? 'Show Less' : 'View More')
                                              : 'No More Text',
                                          style: TextStyle(
                                            color: isLongText
                                                ? (isExpanded ? Colors.red : Colors.indigo)
                                                : Colors.grey,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
      ),
    );
  }
}
