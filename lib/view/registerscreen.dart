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
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

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
        body: Center(
            child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: "Full Name"),
                    ),
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
                    TextField(
                      controller: confirmPasswordController,
                      decoration: const InputDecoration(labelText: "Confirm Password"),
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
                        child: ElevatedButton(
                          onPressed: registerUserDialog,
                          style: ElevatedButton.styleFrom(backgroundColor: const Color.fromARGB(255, 36, 52, 159)),
                          child: const Text(
                            "Register",
                            style: TextStyle(color: Colors.white),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        )));
  }

  void registerUserDialog() {
    String fullName = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    if (fullName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty || phone.isEmpty || address.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Passwords do not match")));
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
        });
  }

  Future<void> registerUser() async {
    String fullName = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;
    String phone = phoneController.text;
    String address = addressController.text;

    try {
      var response = await http.post(Uri.parse("${MyConfig.myurl}/wtms/wtms/php/register_worker.php"),
        body: {
          "name": fullName,
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
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Failed to register")));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Server Error: ${response.statusCode}")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }
}
