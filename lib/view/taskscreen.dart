// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/myconfig.dart';
import 'package:wtms/model/task.dart';
import 'package:wtms/view/submit_taskscreen.dart';

class TaskScreen extends StatefulWidget {
  final int workerId;
  const TaskScreen({super.key, required this.workerId});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> with TickerProviderStateMixin {
  List<Task> tasks = [];
  bool isLoading = false;
  bool isRefreshing = false;
  String? errorMessage;
  late final AnimationController _refreshController;

  @override
  void initState() {
    super.initState();
    _refreshController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    fetchTasks();
  }

  @override
  void dispose() {
    _refreshController.dispose();
    super.dispose();
  }

  Future<void> fetchTasks({bool showSnackbar = false}) async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      isRefreshing = true;
      errorMessage = null;
    });
    _refreshController.repeat();

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
          isRefreshing = false;
        });

        if (showSnackbar) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Tasks refreshed successfully')),
          );
        }
      } else {
        throw Exception('Server error: ${response.statusCode}');
      }
    } on TimeoutException {
      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage = 'Request timed out. Please try again.';
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isRefreshing = false;
        errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      _refreshController.reset();
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

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case "completed":
        return Icons.check_circle;
      case "in progress":
        return Icons.hourglass_bottom;
      case "pending":
      default:
        return Icons.pending;
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
        child: isLoading && tasks.isEmpty
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
                          onPressed: () => fetchTasks(showSnackbar: false),
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
                            Text("No tasks assigned", style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => fetchTasks(showSnackbar: true),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(8),
                          itemCount: tasks.length,
                          itemBuilder: (context, index) {
                            final task = tasks[index];
                            final statusColor = _getStatusColor(task.status);
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 6),
                              child: Material(
                                elevation: 3,
                                borderRadius: BorderRadius.circular(16),
                                color: Colors.white,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
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
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border(
                                        left: BorderSide(color: statusColor, width: 6),
                                      ),
                                    ),
                                    child: ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(
                                        _getStatusIcon(task.status),
                                        color: statusColor,
                                        size: 36,
                                      ),
                                      title: Text(
                                        task.title,
                                        style: const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      subtitle: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 4),
                                          Text(task.description),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              const Icon(Icons.calendar_today, size: 16),
                                              const SizedBox(width: 4),
                                              Text('Due: ${task.dueDate}'),
                                            ],
                                          ),
                                          if (task.status.toLowerCase() == 'completed')
                                            Padding(
                                              padding: const EdgeInsets.only(top: 4),
                                              child: Row(
                                                children: const [
                                                  Icon(Icons.check, size: 16, color: Colors.green),
                                                  SizedBox(width: 4),
                                                  Text('Submitted',
                                                      style: TextStyle(color: Colors.green)),
                                                ],
                                              ),
                                            ),
                                        ],
                                      ),
                                      trailing: Chip(
                                        label: Text(
                                          task.status.toUpperCase(),
                                          style: TextStyle(
                                            color: statusColor,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        backgroundColor: statusColor.withOpacity(0.1),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                      ),
                                    ),
                                  ),
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
