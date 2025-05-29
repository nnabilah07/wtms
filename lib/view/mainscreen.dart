import 'package:flutter/material.dart';
import 'package:wtms/model/worker.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/profilescreen.dart';
import 'package:wtms/view/registerscreen.dart';
import 'package:wtms/view/taskscreen.dart';

class MainScreen extends StatefulWidget {
  final Worker worker;
  const MainScreen({super.key, required this.worker});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  bool get isGuest => widget.worker.workerId == "0";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // Disable Android back button
      child: Scaffold(
        appBar: AppBar(
          leading: null, // Removes the back button
          title: const Text(
            "WTMS: Worker Task Management System",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 36, 52, 159),
          actions: isGuest
              ? []
              : [
                  IconButton(
                    onPressed: () {
                      _showLogoutConfirmationDialog(context);
                    },
                    icon: const Icon(Icons.exit_to_app, color: Colors.white),
                  ),
                ],
        ),
        body: Center(
          child: isGuest ? _buildGuestView(context) : _buildUserView(context),
        ),
        floatingActionButton: isGuest
            ? null
            : FloatingActionButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Task creation feature coming soon!"),
                  ));
                },
                backgroundColor: const Color.fromARGB(255, 36, 52, 159),
                child: const Icon(Icons.add, color: Colors.white),
              ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            "assets/images/main_image.jpeg",
            width: 300,
            height: 300,
            fit: BoxFit.cover,
          ),
          const SizedBox(height: 10),
          const Text(
            "Hi! Welcome to Worker Task Management System, Guest! Please choose an option to proceed.",
            style: TextStyle(fontSize: 18, color: Colors.black),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 36, 52, 159),
            ),
            child: const Text("Log in", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const RegisterScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 36, 52, 159),
            ),
            child:
                const Text("Register", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildUserView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Hi, Welcome ${widget.worker.workerFullName}!",
          style: TextStyle(
            fontSize: 24,
            color: Colors.blue.shade800,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            final workerIdStr = widget.worker.workerId;
            if (workerIdStr != null && int.tryParse(workerIdStr) != null) {
              final workerIdInt = int.parse(workerIdStr);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TaskScreen(workerId: workerIdInt),
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Invalid worker ID.")),
              );
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color.fromARGB(255, 36, 52, 159),
          ),
          child: const Text("View Tasks", style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ProfileScreen(worker: widget.worker),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade900,
          ),
          child: const Text("View Profile", style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to log out?"),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );
  }
}
