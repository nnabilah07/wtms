// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:wtms/myconfig.dart';
import 'package:wtms/model/task.dart';
import 'package:wtms/view/submit_taskscreen.dart';

class TaskScreen extends StatefulWidget {
  final int workerId;
  const TaskScreen({super.key, required this.workerId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> tasks = [];
  bool isLoading = false;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      var url = Uri.parse("${MyConfig.myurl}/wtms/wtms/php/get_works.php");

      var response = await http.post(
        url,
        headers: {'Content-Type': 'application/x-www-form-urlencoded'},
        body: {'worker_id': widget.workerId.toString()},
      ).timeout(const Duration(seconds: 10));

      if (kDebugMode) {
        debugPrint("Response status: ${response.statusCode}");
        debugPrint("Response body: ${response.body}");
      }

      if (response.statusCode == 200) {
        try {
          final responseData = json.decode(response.body);

          List<dynamic> taskList = [];
          if (responseData is List) {
            taskList = responseData;
          } else if (responseData is Map && responseData.containsKey('data')) {
            taskList = responseData['data'] ?? [];
          }

          setState(() {
            tasks = taskList.map((json) => Task.fromJson(json)).toList();
            isLoading = false;
          });
        } catch (e) {
          throw Exception('Failed to parse response: $e');
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        isLoading = false;
        errorMessage = 'Request timed out. Please try again.';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Colors.green;
      case "in progress":
        return Colors.orange;
      case "pending":
      default:
        return Colors.red;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Assigned Tasks",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
      ),
      body: isLoading && tasks.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 64, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage!,
                        style: const TextStyle(fontSize: 16, color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchTasks,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : tasks.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.inbox, size: 64, color: Colors.grey),
                          SizedBox(height: 10),
                          Text("No tasks assigned", 
                          style: TextStyle(fontSize: 16)
                          ),
                        ],
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: fetchTasks,
                      child: ListView.builder(
                        itemCount: tasks.length,
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            elevation: 3,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            color: const Color.fromARGB(255, 241, 247, 255),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(12),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SubmitTaskScreen(
                                      taskId: int.parse(task.id),
                                      taskTitle: task.title,
                                      workerId: widget.workerId,
                                    ),
                                  ),
                                ).then((_) => fetchTasks());
                              },
                              title: Text(
                                task.title,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.description, size: 18, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          task.description,
                                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today, size: 18, color: Colors.black54),
                                      const SizedBox(width: 6),
                                      Text(
                                        "Due Date: ${task.dueDate}",
                                        style: const TextStyle(fontSize: 14, color: Colors.black87),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: _getStatusColor(task.status).withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: _getStatusColor(task.status),
                                    width: 1.2,
                                  ),
                                ),
                                child: Text(
                                  task.status.toUpperCase(),
                                  style: TextStyle(
                                    color: _getStatusColor(task.status),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
    );
  }
}
