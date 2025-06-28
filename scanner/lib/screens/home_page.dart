import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import all other screens used in the app
import 'image_capture_screen.dart';
import 'crop_calendar_screen.dart';
import 'weather_info_screen.dart';
import 'farmer_notes_screen.dart';
import 'last_scan_screen.dart';
import 'farming_tools_rental_screen.dart'; // Farming Tools Rental Screen
import 'login_screen.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userPhone;

  const HomePage({Key? key, required this.userName, required this.userPhone})
      : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ImageCaptureScreen(),
    CropCalendarScreen(),
    WeatherInfoScreen(),
    FarmerNotesScreen(),
    LastScanScreen(),
  ];

  final List<String> _titles = [
    "Plant Scanner",
    "Crop Care Calendar",
    "Weather Info",
    "Farmer Notes",
    "Last Scan",
  ];

  final List<IconData> _icons = [
    Icons.search,
    Icons.calendar_today,
    Icons.wb_sunny,
    Icons.note,
    Icons.history,
  ];

  final List<Color> _colors = [
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  void _onItemTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
    Navigator.pop(context); // Close the drawer
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all stored user data
    print('User logged out - Cleared all stored data');
    
    // Navigate to login screen and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _titles[_selectedIndex],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.green,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.shade800,
                Colors.green.shade400,
              ],
            ),
          ),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.green.shade900,
                ),
                accountName: Text(
                  widget.userName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                accountEmail: Text(
                  widget.userPhone,
                  style: const TextStyle(fontSize: 16),
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.userName[0].toUpperCase(),
                    style: TextStyle(
                      fontSize: 40,
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              ...List.generate(_screens.length, (index) {
                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _colors[index].withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      _icons[index],
                      color: _colors[index],
                    ),
                  ),
                  title: Text(
                    _titles[index],
                    style: TextStyle(
                      fontWeight: _selectedIndex == index ? FontWeight.bold : FontWeight.normal,
                      color: _selectedIndex == index ? Colors.green.shade900 : Colors.black87,
                    ),
                  ),
                  onTap: () => _onItemTap(index),
                  selected: _selectedIndex == index,
                  selectedTileColor: Colors.green.shade100,
                );
              }),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.build,
                    color: Colors.orange,
                  ),
                ),
                title: const Text(
                  'Farming Tools Rental',
                  style: TextStyle(fontWeight: FontWeight.w500),
                ),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FarmingToolsRentalScreen(),
                    ),
                  );
                },
              ),
              const Divider(
                color: Colors.white,
                thickness: 0.5,
              ),
              ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.logout,
                    color: Colors.red,
                  ),
                ),
                title: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                onTap: _logout,
              ),
            ],
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: _screens[_selectedIndex],
        ),
      ),
    );
  }
}
