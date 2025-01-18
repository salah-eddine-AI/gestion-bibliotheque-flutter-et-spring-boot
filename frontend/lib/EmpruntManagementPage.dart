import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpruntManagementPage extends StatefulWidget {
  @override
  _EmpruntManagementPageState createState() => _EmpruntManagementPageState();
}

class _EmpruntManagementPageState extends State<EmpruntManagementPage> {
  List<dynamic> emprunts = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEmprunts();
  }

  Future<void> fetchEmprunts() async {
    final response = await http.get(Uri.parse('http://localhost:8085/emprunt'));
    if (response.statusCode == 200) {
      setState(() {
        emprunts = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load emprunts');
    }
  }

  Future<void> searchEmpruntById(String id) async {
    final response = await http.get(Uri.parse('http://localhost:8085/emprunt/$id'));
    if (response.statusCode == 200) {
      setState(() {
        emprunts = [json.decode(response.body)];
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Emprunt not found')),
      );
    }
  }

  Future<void> fetchActiveEmprunts() async {
    final response = await http.get(Uri.parse('http://localhost:8085/emprunt/allactiveemprunts'));
    if (response.statusCode == 200) {
      setState(() {
        emprunts = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load active emprunts')),
      );
    }
  }

  Future<void> setAsTerminer(int empruntId) async {
    final response = await http.put(Uri.parse('http://localhost:8085/emprunt/setasterminer/$empruntId'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marquer comme Terminé')),
      );
      fetchEmprunts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as Terminé')),
      );
    }
  }

  Future<void> setAsRetard(int empruntId) async {
    final response = await http.put(Uri.parse('http://localhost:8085/emprunt/setasretard/$empruntId'));
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('marquer comme Retard')),
      );
      fetchEmprunts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to mark as Retard')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    decoration: InputDecoration(
                      labelText: 'entre Emprunt ID',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.search),
                        onPressed: () {
                          final id = searchController.text.trim();
                          if (id.isNotEmpty) {
                            searchEmpruntById(id);
                          }
                        },
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: fetchActiveEmprunts,
                  child: Text('Les Emprunts Pas Payés'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: emprunts.length,
              itemBuilder: (context, index) {
                final emprunt = emprunts[index];
                final isActionDisabled = emprunt['empruntStatus'] == 'RETARD' || emprunt['empruntStatus'] == 'TERMINE';

                return Card(
                  child: ListTile(
                    title: Text('ID: ${emprunt['id']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Date Emprunt: ${emprunt['dateEmprunt']}'),
                        Text('Date Retour: ${emprunt['dateRetour']}'),
                        Text('Status: ${emprunt['empruntStatus']}'),
                        Text('Prix Total: ${emprunt['prixTotal']}'),
                        Text('Utilisateur: ${emprunt['utilisateur']['email']}'),
                        Text('Livre: ${emprunt['livre']['titre']}'),
                      ],
                    ),
                    trailing: Wrap(
                      spacing: 8.0,
                      children: [
                        ElevatedButton(
                          onPressed: isActionDisabled ? null : () => setAsTerminer(emprunt['id']),
                          child: Text('Terminer'),
                        ),
                        ElevatedButton(
                          onPressed: isActionDisabled ? null : () => setAsRetard(emprunt['id']),
                          child: Text('Retarder'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
