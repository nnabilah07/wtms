import 'package:flutter/material.dart';
import 'package:wtms/model/worker.dart';
import 'package:wtms/view/loginscreen.dart';
import 'package:wtms/view/registerscreen.dart';
import 'package:wtms/view/taskscreen.dart';
import 'package:wtms/view/historyscreen.dart';
import 'package:wtms/view/profilescreen.dart';

class MainScreen extends StatefulWidget {
  final Worker worker;
  final int initialIndex;

  const MainScreen({super.key, required this.worker, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;
  late List<Widget> _pages;

  bool get isGuest => widget.worker.workerId == "0";

  final Color primaryColor = const Color.fromARGB(255, 36, 52, 159);

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _pages = isGuest
        ? [Center(child: _buildGuestView(context))]
        : [
            TaskScreen(workerId: int.parse(widget.worker.workerId!)),
            HistoryScreen(workerId: int.parse(widget.worker.workerId!)),
            ProfileScreen(worker: widget.worker),
          ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0ECFF), Color(0xFFD1C4E9)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: isGuest
            ? _buildGuestView(context)
            : Scaffold(
                backgroundColor: Colors.transparent,
                appBar: _currentIndex != 2
                    ? AppBar(
                        iconTheme: const IconThemeData(color: Colors.white),
                        title: Text(
                          _currentIndex == 0 ? "Task Screen" : "History Screen",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        backgroundColor: primaryColor,
                        actions: [
                          IconButton(
                            icon: const Icon(Icons.exit_to_app, color: Colors.white),
                            onPressed: () => _showLogoutConfirmationDialog(context),
                          ),
                        ],
                      )
                    : null,
                drawer: _currentIndex != 2 ? _buildDrawer() : null,
                body: _pages[_currentIndex],
                bottomNavigationBar: _currentIndex != 2
                    ? BottomNavigationBar(
                        currentIndex: _currentIndex,
                        onTap: (index) {
                          setState(() => _currentIndex = index);
                        },
                        selectedItemColor: primaryColor,
                        items: const [
                          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
                          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
                          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
                        ],
                      )
                    : null,
              ),
      ),
    );
  }

  Widget _buildGuestView(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                "assets/images/main_image.jpeg",
                width: 280,
                height: 280,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 25),
            const Text(
              "Hi Guest!\nWelcome to Worker Task Management System.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              "Please log in or register to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text("Log in", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(200, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text("Register", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                minimumSize: const Size(200, 45),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 5,
              ),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(widget.worker.workerFullName ?? 'Guest'),
            accountEmail: Text(widget.worker.workerEmail ?? 'No email'),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                widget.worker.workerFullName?.substring(0, 1).toUpperCase() ?? 'G',
                style: const TextStyle(fontSize: 30, color: Colors.indigo),
              ),
            ),
            decoration: BoxDecoration(color: primaryColor),
          ),
          ListTile(
            leading: const Icon(Icons.task, color: Colors.indigo),
            title: const Text('Tasks'),
            onTap: () {
              setState(() => _currentIndex = 0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.history, color: Colors.indigo),
            title: const Text('History'),
            onTap: () {
              setState(() => _currentIndex = 1);
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Profile'),
            onTap: () {
              setState(() => _currentIndex = 2);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Logout'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutConfirmationDialog(context);
            },
          ),
        ],
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            child: const Text("Logout"),
            onPressed: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
