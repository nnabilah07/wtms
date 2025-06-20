import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/model/worker.dart';
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/profilescreen.dart';
import 'package:wtms/view/registerscreen.dart';
import 'package:wtms/view/mainscreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadCredentials();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Worker defaultWorker = Worker(
              workerId: "0",
              workerFullName: "Guest",
              workerEmail: "",
              workerPhone: "",
              workerAddress: "",
            );
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => MainScreen(worker: defaultWorker)),
            );
          },
        ),
        title: const Text(
          "Worker Login",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0ECFF),
              Color(0xFFD1C4E9),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      "assets/images/worker_icon.jpeg",
                      height: 200,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: const InputDecoration(labelText: "Email"),
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: passwordController,
                          decoration: const InputDecoration(labelText: "Password"),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Checkbox(
                              value: isChecked,
                              onChanged: (value) {
                                setState(() => isChecked = value!);
                                storeCredentials(
                                  emailController.text,
                                  passwordController.text,
                                  isChecked,
                                );
                              },
                            ),
                            const Text("Remember Me"),
                          ],
                        ),
                        const SizedBox(height: 16),
                        isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton.icon(
                                icon: const Icon(Icons.login, color: Colors.white),
                                label: const Text("Login", style: TextStyle(color: Colors.white)),
                                onPressed: loginWorker,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 36, 52, 159),
                                  minimumSize: const Size.fromHeight(45),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                              ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 15),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                  },
                  child: const Text("Register an account?", style: TextStyle(color: Colors.black)),
                ),
                TextButton(
                  onPressed: () {
                    // Future implementation
                  },
                  child: const Text("Forgot Password?", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  bool isValidPassword(String password) {
    return password.length >= 6;
  }

  Future<void> loginWorker() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showSnackBar("Please fill all fields", Colors.red);
      return;
    }

    if (!isValidEmail(email)) {
      _showSnackBar("Invalid email format", Colors.red);
      return;
    }

    if (!isValidPassword(password)) {
      _showSnackBar("Password must be at least 6 characters", Colors.red);
      return;
    }

    setState(() => isLoading = true);

    try {
      var response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/wtms/php/login_worker.php"),
        body: {
          "email": email,
          "password": password,
        },
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          Worker worker = Worker.fromJson(jsondata['data']);
          _showSnackBar("Welcome ${worker.workerFullName}", Colors.green);

          // Show success dialog before navigating
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              Future.delayed(const Duration(seconds: 2), () {
                Navigator.of(context).pop(); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ProfileScreen(worker: worker)),
                );
              });
              return AlertDialog(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 60),
                    SizedBox(height: 12),
                    Text("Login successful!", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            },
          );
        } else {
          _showSnackBar("Login failed: ${jsondata['message']}", Colors.red);
        }
      } else {
        _showSnackBar("Server error: ${response.statusCode}", Colors.red);
      }
    } catch (e) {
      setState(() => isLoading = false);
      _showSnackBar("Error: $e", Colors.red);
    }
  }

  void _showSnackBar(String message, Color bgColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: bgColor),
    );
  }

  Future<void> storeCredentials(String email, String password, bool isChecked) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (isChecked) {
      await prefs.setString('email', email);
      await prefs.setString('pass', password);
      await prefs.setBool('remember', isChecked);
    } else {
      await prefs.remove('email');
      await prefs.remove('pass');
      await prefs.remove('remember');
      emailController.clear();
      passwordController.clear();
    }
  }

  Future<void> loadCredentials() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? email = prefs.getString('email');
    String? password = prefs.getString('pass');
    bool? remember = prefs.getBool('remember');
    if (remember == true && email != null && password != null) {
      emailController.text = email;
      passwordController.text = password;
      setState(() => isChecked = true);
    }
  }
}
