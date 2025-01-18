import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'UserManagementPage.dart'; 
import 'LivreManagementPage.dart'; 
import 'EmpruntManagementPage.dart'; 
import 'LoginPage.dart'; 
import 'StatisticsPage.dart'; 

class AdminPage extends StatelessWidget {
  final int userId;

  const AdminPage({Key? key, required this.userId}) : super(key: key);

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId'); 
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()), 
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
       
            _buildCard(
              context,
              text: 'Gestion des Utilisateurs',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UserManagementPage()),
                );
              },
            ),
            SizedBox(height: 16),
            _buildCard(
              context,
              text: 'Gestion des Livres',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LivreManagementPage()),
                );
              },
            ),
            SizedBox(height: 16),
            _buildCard(
              context,
              text: 'Gestion des Emprunts',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EmpruntManagementPage()),
                );
              },
            ),
            SizedBox(height: 30),

            _buildCard(
              context,
              text: 'Statistics',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatisticsPage()),
                );
              },
            ),
            SizedBox(height: 30),

            _buildCard(
              context,
              text: 'Logout',
              onPressed: () => logout(context),
              icon: Icons.logout,
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context,
      {required String text, required VoidCallback onPressed, IconData? icon, Color color = Colors.deepPurple}) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              if (icon != null)
                Icon(icon, color: Colors.white),
              SizedBox(width: icon != null ? 16.0 : 0),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
      color: color, 
    );
  }
}
