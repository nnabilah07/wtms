import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wtms/model/worker.dart';
import 'package:wtms/myconfig.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/mainscreen.dart';

class ProfileScreen extends StatefulWidget {
  final Worker worker;
  const ProfileScreen({super.key, required this.worker});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _addressController;
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.worker.workerFullName);
    _emailController = TextEditingController(text: widget.worker.workerEmail);
    _phoneController = TextEditingController(text: widget.worker.workerPhone);
    _addressController = TextEditingController(text: widget.worker.workerAddress);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    bool isValidEmail(String email) {
      final emailRegex = RegExp(r'^[\w\.-]+@[a-zA-Z\d\.-]+\.[a-zA-Z]{2,}$');
      return emailRegex.hasMatch(email);
    }

    bool isValidPhone(String phone) {
      final phoneRegex = RegExp(r'^\+?[0-9]{7,15}$');
      return phoneRegex.hasMatch(phone);
    }

    try {
      // Validate inputs
      if (_nameController.text.isEmpty) {
        throw Exception('Full name is required');
      }
      if (!isValidEmail(_emailController.text)) {
        throw Exception('Invalid email format');
      }
      if (_phoneController.text.isEmpty) {
        throw Exception('Phone number is required');
      }
      if (!isValidPhone(_phoneController.text)) {
        throw Exception('Invalid phone number format');
      }

      // Prepare request
      final url = "${MyConfig.myurl}/wtms/wtms/php/update_profile.php";
      final body = json.encode({
        'worker_id': widget.worker.workerId,
        'workerFullName': _nameController.text,
        'workerEmail': _emailController.text,
        'workerPhone': _phoneController.text,
        'workerAddress': _addressController.text,
      });

      debugPrint("POST to: $url");
      debugPrint("Payload: $body");

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      debugPrint("HTTP Status: ${response.statusCode}");
      debugPrint("HTTP Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['status'] == 'success') {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(data['message'] ?? 'Profile updated successfully')),
          );

          setState(() {
            _isEditing = false;
            widget.worker.workerFullName = _nameController.text;
            widget.worker.workerEmail = _emailController.text;
            widget.worker.workerPhone = _phoneController.text;
            widget.worker.workerAddress = _addressController.text;
          });
        } else {
          throw Exception(data['message'] ?? 'Failed to update profile');
        }
      } else {
        throw Exception('Server responded with status ${response.statusCode}');
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request timed out. Please check your connection.')),
      );
    } on http.ClientException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Network error: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString().replaceFirst('Exception: ', '')}')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    bool? confirmed = await showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        title: const Text("Logout", style: TextStyle(color: Colors.indigo)),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, false),
            child: const Text("Cancel", style: TextStyle(color: Colors.indigo)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx, true),
            child: const Text("Logout", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      bool remember = prefs.getBool("remember") ?? false;
      String? email = prefs.getString("email");
      String? password = prefs.getString("pass");

      await prefs.clear();

      if (remember) {
        await prefs.setBool("remember", true);
        if (email != null) await prefs.setString("email", email);
        if (password != null) await prefs.setString("pass", password);
      }

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color readOnlyTextColor = Colors.indigo.shade900;

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text("Profile Screen",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            )),
        backgroundColor: const Color.fromARGB(255, 36, 52, 159),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save : Icons.edit, color: Colors.white),
            onPressed: _isEditing ? _updateProfile : _toggleEdit,
          ),
        ],
      ),
      drawer: _buildDrawer(),
      bottomNavigationBar: _isEditing ? null : _buildBottomNavBar(),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0ECFF), Color(0xFFD1C4E9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Color(0xFFF6F9FF),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFB0BEC5), width: 1.2), // Platinum border
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF9575CD).withOpacity(0.1), // Smokey Purple shadow
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color.fromARGB(255, 181, 186, 214),
                      child: Icon(Icons.person, size: 50, color: Colors.indigo[800]),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '@${widget.worker.workerUsername ?? "username"}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.indigo.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      controller: _nameController,
                      label: 'Full Name',
                      icon: Icons.person,
                      readOnlyColor: readOnlyTextColor,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      readOnlyColor: readOnlyTextColor,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      icon: Icons.phone,
                      keyboardType: TextInputType.phone,
                      readOnlyColor: readOnlyTextColor,
                    ),
                    const SizedBox(height: 16),
                    buildTextField(
                      controller: _addressController,
                      label: 'Address',
                      icon: Icons.location_on,
                      maxLines: 3,
                      readOnlyColor: readOnlyTextColor,
                    ),
                    const SizedBox(height: 20),
                    if (_isEditing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: _toggleEdit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(255, 142, 142, 142),
                            ),
                            child: const Text('Cancel', style: TextStyle(color: Colors.white)),
                          ),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.indigo),
                            child: const Text('Save', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    if (!_isEditing) ...[
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => _logout(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 156, 43, 35),
                        ),
                        child: const Text('Logout', style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
          if (_isLoading)
            const Opacity(
              opacity: 0.6,
              child: ModalBarrier(dismissible: false, color: Colors.black),
            ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
        ],
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    Color? readOnlyColor,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      enabled: _isEditing,
      style: TextStyle(color: _isEditing ? Colors.black : (readOnlyColor ?? Colors.black)),
      decoration: InputDecoration(
        labelText: label,
        hintText: _isEditing ? 'Enter your $label' : null,
        labelStyle: TextStyle(color: _isEditing ? Colors.black : (readOnlyColor ?? Colors.black)),
        prefixIcon: Icon(icon, color: Colors.indigo),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.indigo.shade700),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return BottomNavigationBar(
      currentIndex: 2,
      selectedItemColor: const Color.fromARGB(255, 36, 52, 159),
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(worker: widget.worker, initialIndex: 0)),
          );
        } else if (index == 1) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MainScreen(worker: widget.worker, initialIndex: 1)),
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
        BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.worker.workerFullName ?? 'No Name', style: const TextStyle(color: Colors.white)),
            accountEmail: Text(widget.worker.workerEmail ?? 'No Email', style: const TextStyle(color: Colors.white)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.indigo, size: 40),
            ),
            decoration: const BoxDecoration(color: Color.fromARGB(255, 36, 52, 159)),
          ),
          ListTile(
            leading: const Icon(Icons.task, color: Colors.indigo),
            title: const Text('Tasks'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(worker: widget.worker)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.indigo),
            title: const Text('History'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainScreen(worker: widget.worker, initialIndex: 1)),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Profile'),
            onTap: () => Navigator.pop(context),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _logout(context);
            },
          ),
        ],
      ),
    );
  }
}
