import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoriquePage extends StatelessWidget {
  final int userId;

  const HistoriquePage({Key? key, required this.userId}) : super(key: key);

  Future<List<dynamic>> fetchEmpruntHistory(int userId) async {
    final response = await http.get(Uri.parse('http://localhost:8085/emprunt/historiqueofemprunts/$userId'));

    if (response.statusCode == 200) {
      return json.decode(response.body); 
    } else {
      throw Exception('Failed to load emprunt history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Mes Emprunts Historique')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchEmpruntHistory(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final emprunts = snapshot.data!;

            return ListView.builder(
              itemCount: emprunts.length,
              itemBuilder: (context, index) {
                final emprunt = emprunts[index];
                final livre = emprunt['livre'];
                return ListTile(
                  title: Text('Livre: ${livre['titre']}'),
                  subtitle: Text(
                    'Date Emprunt: ${emprunt['dateEmprunt']}\n'
                    'Date Retour: ${emprunt['dateRetour']}\n'
                    'Prix Total: ${emprunt['prixTotal']}\n'
                    'Status: ${emprunt['empruntStatus']}',
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('Aucun historique disponible'));
          }
        },
      ),
    );
  }
}
