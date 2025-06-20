import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/myconfig.dart';

class SubmitTaskScreen extends StatefulWidget {
  final int taskId;
  final String taskTitle;
  final int workerId;

  const SubmitTaskScreen({
    super.key,
    required this.taskId,
    required this.taskTitle,
    required this.workerId,
  });

  @override
  State<SubmitTaskScreen> createState() => _SubmitTaskScreenState();
}

class _SubmitTaskScreenState extends State<SubmitTaskScreen> {
  final TextEditingController _submissionController = TextEditingController();
  final FocusNode _submissionFocusNode = FocusNode();
  bool _isSubmitting = false;

  bool get _isValidSubmission {
    final text = _submissionController.text.trim();
    return text.length >= 10 && text.length <= 200;
  }

  Future<void> submitCompletion() async {
    setState(() => _isSubmitting = true);

    try {
      final url = Uri.parse("${MyConfig.myurl}/wtms/wtms/php/submit_work.php");

      final requestData = {
        'work_id': widget.taskId,
        'worker_id': widget.workerId,
        'submission_text': _submissionController.text.trim(),
      };

      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(requestData),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Submission successful!')),
          );
          Navigator.pop(context, true);
        } else {
          throw Exception(responseData['message'] ?? 'Submission failed');
        }
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Check your connection.')),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _confirmSubmissionDialog() async {
    if (!_isValidSubmission) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Submission"),
        content: const Text("Are you sure you want to submit this task completion?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
            child: const Text("Confirm", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      submitCompletion();
    }
  }

  @override
  void dispose() {
    _submissionFocusNode.dispose();
    _submissionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int textLength = _submissionController.text.length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Submit Task Completion",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE3F2FD), Color(0xFFF8BBD0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Improved Task Box
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFBBDEFB), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Assigned Task',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.indigo,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Divider(
                      thickness: 1.2,
                      color: Color(0xFFBBDEFB),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      widget.taskTitle,
                      style: const TextStyle(
                        fontSize: 17,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Completion Details:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.indigo,
                ),
              ),
              const SizedBox(height: 8),
              // Input Box
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF6F9FF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF90CAF9), width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        Icon(Icons.assignment_outlined, color: Color(0xFF1976D2)),
                        SizedBox(width: 8),
                        Text(
                          'Your Completion Details',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _submissionController,
                      focusNode: _submissionFocusNode,
                      maxLines: 5,
                      maxLength: 200,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        hintText: 'Minimum 10 characters required…',
                        border: InputBorder.none,
                        hintStyle: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '$textLength/200',
                          style: TextStyle(
                            color: textLength > 200 ? Colors.red : Colors.grey,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            _submissionController.clear();
                            setState(() {});
                          },
                          child: const Text('Clear Text'),
                        ),
                      ],
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        _isValidSubmission ? Icons.check_circle : Icons.error_outline,
                        color: _isValidSubmission ? Colors.green : Colors.orange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: _isSubmitting ? const SizedBox.shrink() : const Icon(Icons.send),
                  label: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Submit Completion'),
                  onPressed: _isSubmitting || !_isValidSubmission
                      ? null
                      : _confirmSubmissionDialog,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey,
                    disabledForegroundColor: Colors.white70,
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
