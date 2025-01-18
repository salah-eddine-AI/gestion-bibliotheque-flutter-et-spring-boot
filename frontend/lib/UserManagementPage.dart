import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserManagementPage extends StatefulWidget {
  const UserManagementPage({Key? key}) : super(key: key);

  @override
  _UserManagementPageState createState() => _UserManagementPageState();
}

class _UserManagementPageState extends State<UserManagementPage> {
  late Future<List<dynamic>> usersFuture;

  @override
  void initState() {
    super.initState();
    usersFuture = fetchUsers();
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(Uri.parse('http://localhost:8085/utilisateur/all'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load users');
    }
  }

  Future<void> deleteUser(int userId) async {
    final response = await http.delete(Uri.parse('http://localhost:8085/utilisateur/delete/$userId'));
    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lutilisateur a été supprimé avec succès')),
      );
      setState(() {
        usersFuture = fetchUsers();
      });
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Utilisateur non trouvé')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete user')),
      );
    }
  }

  void updateUser(BuildContext context, Map<String, dynamic> user) {
    TextEditingController nameController = TextEditingController(text: user['nom']);
    TextEditingController emailController = TextEditingController(text: user['email']);
    TextEditingController passwordController = TextEditingController(text: user['motDePasse']);
    String selectedRole = user['role'];
    final roles = ['UTILISATEUR', 'BIBLIOTHECAIRE'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(''),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Nom'),
            ),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(labelText: 'Mot de Passe'),
            ),
            DropdownButton<String>(
              value: selectedRole,
              onChanged: (value) {
                setState(() {
                  selectedRole = value!;
                });
              },
              items: roles.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Text(role),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final updatedUser = {
                'nom': nameController.text,
                'email': emailController.text,
                'motDePasse': passwordController.text,
                'role': selectedRole,
                'statisticNbrEmpruntTotal': user['statisticNbrEmpruntTotal'],
                'nbrEmpruntRetarder': user['nbrEmpruntRetarder'],
              };

              final response = await http.put(
                Uri.parse('http://localhost:8085/utilisateur/update/${user['id']}'),
                headers: {'Content-Type': 'application/json'},
                body: json.encode(updatedUser),
              );

              if (response.statusCode == 200) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('User updated successfully')),
                );
                setState(() {
                  usersFuture = fetchUsers();
                });
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to update user')),
                );
              }
              Navigator.pop(context);
            },
            child: Text('Update'),
          ),
        ],
      ),
    );
  }

  Future<List<dynamic>> fetchLoanHistory(int userId) async {
    final response = await http.get(Uri.parse('http://localhost:8085/emprunt/historiqueofemprunts/$userId'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else if (response.statusCode == 404) {
      throw Exception('Utilisateur non trouvé');
    } else {
      throw Exception('Failed to load loan history');
    }
  }

  void showLoanHistory(BuildContext context, int userId) async {
    try {
      List<dynamic> loanHistory = await fetchLoanHistory(userId);

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Historique des Emprunts'),
          content: loanHistory.isEmpty
              ? Text('Aucun emprunt trouvé pour cet utilisateur.')
              : SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: loanHistory.length,
                    itemBuilder: (context, index) {
                      final loan = loanHistory[index];
                      return ListTile(
                        title: Text('Livre: ${loan['livre']['titre']}'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Date Emprunt: ${loan['dateEmprunt']}'),
                            Text('Date Retour: ${loan['dateRetour']}'),
                            Text('Statut: ${loan['empruntStatus']}'),
                            Text('Prix Total: ${loan['prixTotal']}'),
                          ],
                        ),
                      );
                    },
                  ),
                ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Fermer'),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: FutureBuilder<List<dynamic>>(
        future: usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final users = snapshot.data!;

            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  title: Text(user['nom']),
                  subtitle: Text('Email: ${user['email']}\nRole: ${user['role']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.history),
                        onPressed: () => showLoanHistory(context, user['id']),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => updateUser(context, user),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteUser(user['id']),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Aucun utilisateur disponible'));
          }
        },
      ),
    );
  }
}
