import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/loginscreen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  bool isEmailValid = true;
  bool isPasswordValid = true;
  bool isPasswordMatch = true;
  bool isUsernameValid = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Register Worker",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
        iconTheme: const IconThemeData(color: Colors.white),
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
            child: Container(
              margin: const EdgeInsets.all(16.0),
              child: Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: nameController,
                        decoration: const InputDecoration(labelText: "Full Name"),
                      ),
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                          labelText: "Username",
                          errorText: isUsernameValid ? null : "Username must be at least 4 characters",
                        ),
                      ),
                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                          labelText: "Email",
                          errorText: isEmailValid ? null : "Enter a valid email",
                        ),
                        keyboardType: TextInputType.emailAddress,
                      ),
                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          errorText: isPasswordValid ? null : "Password must be at least 6 characters",
                        ),
                        obscureText: true,
                      ),
                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                          labelText: "Confirm Password",
                          errorText: isPasswordMatch ? null : "Passwords do not match",
                        ),
                        obscureText: true,
                      ),
                      TextField(
                        controller: phoneController,
                        decoration: const InputDecoration(labelText: "Phone"),
                        keyboardType: TextInputType.phone,
                      ),
                      TextField(
                        controller: addressController,
                        decoration: const InputDecoration(labelText: "Address"),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : ElevatedButton(
                                onPressed: registerUserDialog,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 36, 52, 159),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                child: const Text(
                                  "Register",
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
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

  bool isValidUsername(String username) {
    return username.length >= 4;
  }

  void registerUserDialog() {
    String fullName = nameController.text;
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    setState(() {
      isEmailValid = isValidEmail(email);
      isPasswordValid = isValidPassword(password);
      isPasswordMatch = password == confirmPassword;
      isUsernameValid = isValidUsername(username);
    });

    if (fullName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (!isEmailValid || !isPasswordValid || !isPasswordMatch || !isUsernameValid) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Register this account?"),
          content: const Text("Are you sure?"),
          actions: [
            TextButton(
              child: const Text("Ok"),
              onPressed: () {
                Navigator.of(context).pop();
                registerUser();
              },
            ),
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> registerUser() async {
    setState(() {
      _isLoading = true;
    });

    String fullName = nameController.text;
    String username = usernameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    try {
      var response = await http.post(
        Uri.parse("${MyConfig.myurl}/wtms/wtms/php/register_worker.php"),
        body: {
          "name": fullName,
          "username": username,
          "email": email,
          "password": password,
          "phone": phone,
          "address": address,
        },
      );

      print(response.body);

      if (response.statusCode == 200) {
        var jsondata = json.decode(response.body);
        if (jsondata['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Success!")));
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(jsondata['message'] ?? "Failed to register")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
