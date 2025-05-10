import 'package:flutter/material.dart';
import 'package:wtms/model/worker.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/profilescreen.dart';
import 'package:wtms/view/registerscreen.dart';

class MainScreen extends StatefulWidget {
  final Worker worker;
  const MainScreen({super.key, required this.worker});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "WTMS: Worker Task Management System",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, 
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            },
            icon: const Icon(
              Icons.exit_to_app,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: Center(
        child: widget.worker.workerId == "0"
            ? Column(
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
                    "Hi! Welcome to Worker Task Management System, Guest! Please register to proceed.",
                    style: TextStyle(fontSize: 18, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Welcome ${widget.worker.workerFullName}",
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.blue.shade800,
                      fontWeight: FontWeight.bold, // Set text to bold
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("ID: ${widget.worker.workerId}", style: const TextStyle(fontSize: 16)),
                  Text("Email: ${widget.worker.workerEmail}", style: const TextStyle(fontSize: 16)),
                  Text("Phone: ${widget.worker.workerPhone}", style: const TextStyle(fontSize: 16)),
                  Text("Address: ${widget.worker.workerAddress}", style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 30),
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
                      backgroundColor: Colors.blue.shade900, // Background color
                    ),
                    child: const Text(
                      "View Profile",
                      style: TextStyle(color: Colors.white), // Text color set to white
                    ),
                  ),
                ],
              ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (widget.worker.workerId == "0") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const RegisterScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              content: Text("Feature to add new task or product is coming soon!"),
            ));
          }
        },
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}