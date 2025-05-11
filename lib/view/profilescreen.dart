import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/mainscreen.dart';  
import 'package:wtms/model/worker.dart';

class ProfileScreen extends StatelessWidget {
  final Worker worker;

  const ProfileScreen({super.key, required this.worker});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Worker Profile",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold, 
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159), // AppBar background color
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
          color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(worker: worker)), // Navigate back to MainScreen
            );
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255), 
        child: Center( // Center the entire content
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add an image at the top
              Image.asset(
                "assets/images/worker_icon.jpeg", // Path to your image
                scale: 3.5, // Adjust scale as needed
                fit: BoxFit.cover, // Adjust image size/fit as needed
              ),
              SizedBox(height: 20), // Space between image and text
              Text("ID: ${worker.workerId}", style: TextStyle(color: Colors.black)),
              Text("Name: ${worker.workerFullName}", style: TextStyle(color: Colors.black)),
              Text("Email: ${worker.workerEmail}", style: TextStyle(color: Colors.black)),
              Text("Phone: ${worker.workerPhone}", style: TextStyle(color: Colors.black)),
              Text("Address: ${worker.workerAddress}", style: TextStyle(color: Colors.black)),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => logout(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 36, 52, 159), 
                  foregroundColor: Colors.white,
                ),
                child: const Text("Logout"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Logout function
  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
    );
  }
}
