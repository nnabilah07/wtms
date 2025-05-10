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
              MaterialPageRoute(
                builder: (context) => MainScreen(worker: defaultWorker),
              ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset("assets/images/worker_icon.jpeg", height: 200),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      TextField(
                        controller: emailController,
                        decoration: const InputDecoration(labelText: "Email"),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: const InputDecoration(labelText: "Password"),
                        obscureText: true,
                      ),
                      Row(
                        children: [
                          const Text("Remember Me"),
                          Checkbox(
                            value: isChecked,
                            onChanged: (value) {
                              setState(() {
                                isChecked = value!;
                              });
                              storeCredentials(emailController.text, passwordController.text, isChecked);
                            },
                          ),
                        ],
                      ),
                      ElevatedButton(
                        onPressed: loginWorker,
                        style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 36, 52, 159)),
                        child: const Text("Login", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const RegisterScreen()));
              },
              child: const Text("Register an account?"),
            ),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () {},
              child: const Text("Forgot Password?"),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loginWorker() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("Please fill all fields"),
        backgroundColor: Colors.red,
      ));
      return;
    }

    try {
      var response = await http.post(Uri.parse("${MyConfig.myurl}/wtms/wtms/php/login_worker.php"),
        body: {
          "email": email,
          "password": password,
        },
      );

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        print("Response body: ${response.body}");

        if (jsondata['status'] == 'success') {
          var workerData = jsondata['data'];
          Worker worker = Worker.fromJson(workerData);

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Welcome ${worker.workerFullName}"),
            backgroundColor: Colors.green,
          ));

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => ProfileScreen(worker: worker)),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text("Login failed: ${jsondata['message']}"),
            backgroundColor: Colors.red,
          ));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Server error: ${response.statusCode}"),
          backgroundColor: Colors.red,
        ));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Error: $e"),
        backgroundColor: Colors.red,
      ));
    }
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
    if (email != null && password != null && remember != null && remember) {
      emailController.text = email;
      passwordController.text = password;
      setState(() {
        isChecked = remember;
      });
    }
  }
}
