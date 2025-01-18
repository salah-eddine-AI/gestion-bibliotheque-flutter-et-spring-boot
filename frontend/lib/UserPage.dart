import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'UpdateProfilePage.dart';
import 'LoginPage.dart';
import 'LivrePage.dart';
import 'HistoriquePage.dart';

class UserPage extends StatefulWidget {
  final int userId;

  const UserPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<dynamic> overdueEmprunts = [];

  Future<Map<String, dynamic>> fetchUserInfo(int userId) async {
    final response = await http.get(Uri.parse('http://localhost:8085/utilisateur/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load user data');
    }
  }

  Future<void> fetchOverdueEmprunts() async {
    final response = await http.get(Uri.parse('http://localhost:8085/emprunt/retardenotpayemprunts/${widget.userId}'));

    if (response.statusCode == 200) {
      setState(() {
        overdueEmprunts = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load overdue emprunts');
    }
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('userId');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchOverdueEmprunts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          Center(
            child: Stack(
              children: [
                IconButton(
                  icon: Icon(Icons.notifications),
                  onPressed: () {
                    if (overdueEmprunts.isNotEmpty) {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Emprunts'),
                          content: SingleChildScrollView(
                            child: Column(
                              children: overdueEmprunts.map<Widget>((emprunt) {
                                return ListTile(
                                  title: Text('Emprunt ID: ${emprunt['id']}'),
                                  subtitle: Text('Livre: ${emprunt['livre']['titre']}\nDate emprunt: ${emprunt['dateEmprunt']}\nDate retour: ${emprunt['dateRetour']}\nPrix total: ${emprunt['prixTotal']}\nStatu: ${emprunt['empruntStatus']}'),
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text('Emprunt Details'),
                                        content: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('ID: ${emprunt['id']}'),
                                            Text('Date Emprunt: ${emprunt['dateEmprunt']}'),
                                            Text('Date Retour: ${emprunt['dateRetour']}'),
                                            Text('Prix Total: ${emprunt['prixTotal']}'),
                                            Text('Livre: ${emprunt['livre']['titre']}'),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      );
                    }
                  },
                ),
                if (overdueEmprunts.isNotEmpty)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Icon(
                      Icons.circle,
                      size: 10,
                      color: Colors.red,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: fetchUserInfo(widget.userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final userData = snapshot.data!;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Bonjour, ${userData['nom']}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 30),
                  _buildCard(
                    context,
                    text: 'Update Profile',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfilePage(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    context,
                    text: 'Voir les Livres',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LivrePage(userId: widget.userId),
                        ),
                      );
                    },
                  ),
                  SizedBox(height: 16),
                  _buildCard(
                    context,
                    text: 'Mes Emprunt Historique',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoriquePage(userId: widget.userId),
                        ),
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
            );
          } else {
            return Center(child: Text('Aucune donnée disponible'));
          }
        },
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
