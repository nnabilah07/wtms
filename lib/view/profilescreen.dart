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
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(worker: worker)),
            );
          },
        ),
      ),
      body: Container(
        color: const Color.fromARGB(255, 255, 255, 255),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/worker_icon.jpeg",
                scale: 3.5,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
              Text("ID: ${worker.workerId}", style: const TextStyle(color: Colors.black)),
              Text("Name: ${worker.workerFullName}", style: const TextStyle(color: Colors.black)),
              Text("Email: ${worker.workerEmail}", style: const TextStyle(color: Colors.black)),
              Text("Phone: ${worker.workerPhone}", style: const TextStyle(color: Colors.black)),
              Text("Address: ${worker.workerAddress}", style: const TextStyle(color: Colors.black)),
              const SizedBox(height: 20),
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

  void logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Confirm logout dialog
    bool? confirmLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text("Logout"),
            ),
          ],
        );
      },
    );

    if (confirmLogout == true) {
      bool remember = prefs.getBool("remember") ?? false;
      String? email = prefs.getString("email");
      String? password = prefs.getString("pass"); 

      await prefs.clear(); // Clear all preferences

      // If "Remember Me" was checked, restore login info
      if (remember) {
        await prefs.setBool("remember", true);
        if (email != null) await prefs.setString("email", email);
        if (password != null) await prefs.setString("pass", password); 
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }
}
