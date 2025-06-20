import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/model/worker.dart';
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/mainscreen.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      loadWorkerCredentials();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A237E), // Deep indigo
              Color(0xFF512DA8), // Purple shade
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/main_image.jpeg",
                    height: 200,
                    width: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "WTMS",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                backgroundColor: Colors.white24,
                valueColor: AlwaysStoppedAnimation<Color>(
                  Colors.cyanAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> loadWorkerCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = prefs.getString('email') ?? '';
    String password = prefs.getString('password') ?? '';
    bool remember = prefs.getBool('remember') ?? false;

    if (remember && email.isNotEmpty && password.isNotEmpty) {
      try {
        final response = await http.post(
          Uri.parse("${MyConfig.myurl}/wtms/wtms/php/login_worker.php"),
          body: {
            "email": email,
            "password": password,
          },
        );

        if (response.statusCode == 200) {
          var jsondata = json.decode(response.body);
          if (jsondata['status'] == 'success') {
            Worker worker = Worker.fromJson(jsondata['data'][0]);

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setBool('isLoggedIn', true);
            await prefs.setString('workerId', worker.workerId.toString());
            await prefs.setString('workerName', worker.workerFullName ?? '');

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainScreen(worker: worker)),
            );
          } else {
            _showError("Auto-login failed. Proceeding as Guest.");
            _goAsGuest();
          }
        } else {
          _showError("Server error. Proceeding as Guest.");
          _goAsGuest();
        }
      } catch (e) {
        _showError("Connection error. Proceeding as Guest.");
        _goAsGuest();
      }
    } else {
      _goAsGuest();
    }
  }

  void _goAsGuest() {
    Worker guest = Worker(
      workerId: "0",
      workerFullName: "Guest",
      workerEmail: "",
      workerPhone: "",
      workerAddress: "",
      workerPassword: "",
    );
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MainScreen(worker: guest)),
    );
  }

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.redAccent,
        ),
      );
    });
  }
}
