import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LivreManagementPage extends StatefulWidget {
  const LivreManagementPage({Key? key}) : super(key: key);

  @override
  _LivreManagementPageState createState() => _LivreManagementPageState();
}

class _LivreManagementPageState extends State<LivreManagementPage> {
  late Future<List<dynamic>> livresFuture;

  @override
  void initState() {
    super.initState();
    livresFuture = fetchLivres();
  }

  Future<List<dynamic>> fetchLivres() async {
    final response = await http.get(Uri.parse('http://localhost:8085/livre'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<List<dynamic>> fetchCatalogues() async {
    final response = await http.get(Uri.parse('http://localhost:8085/catalogue'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load catalogues');
    }
  }

  Future<void> addLivre(BuildContext context) {
    TextEditingController titleController = TextEditingController();
    TextEditingController authorController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();
    TextEditingController priceController = TextEditingController();
    TextEditingController copiesController = TextEditingController();
    TextEditingController availableController = TextEditingController();
    String? selectedCatalogueId;

    return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: fetchCatalogues(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(content: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return AlertDialog(content: Text('Failed to load catalogues'));
            } else if (snapshot.hasData) {
              final catalogues = snapshot.data!;
              return AlertDialog(
                title: Text(''),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Titre'),
                      ),
                      TextField(
                        controller: authorController,
                        decoration: InputDecoration(labelText: 'Auteur'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                      ),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(labelText: 'Prix Par Jour'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: copiesController,
                        decoration: InputDecoration(labelText: 'Nombre Exemplaires'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: availableController,
                        decoration: InputDecoration(labelText: 'Exemplaires Disponibles'),
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButton<String>(
                        value: selectedCatalogueId,
                        hint: Text('Select Catalogue'),
                        onChanged: (value) {
                          setState(() {
                            selectedCatalogueId = value;
                          });
                        },
                        items: catalogues.map<DropdownMenuItem<String>>((catalogue) {
                          return DropdownMenuItem(
                            value: catalogue['id'].toString(),
                            child: Text(catalogue['nom']),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (selectedCatalogueId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez sélectionner un catalogue')),
                        );
                        return;
                      }

                      final newLivre = {
                        'titre': titleController.text,
                        'auteur': authorController.text,
                        'description': descriptionController.text,
                        'prixParJour': double.parse(priceController.text),
                        'nombreExemplaires': int.parse(copiesController.text),
                        'exemplairesDisponibles': int.parse(availableController.text),
                        'statisticNbrEmpruntTotal': 0,
                        'catalogue': {'id': int.parse(selectedCatalogueId!)},
                      };

                      final response = await http.post(
                        Uri.parse('http://localhost:8085/livre'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(newLivre),
                      );

                      if (response.statusCode == 201) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Livre ajouté avec succès')),
                        );
                        setState(() {
                          livresFuture = fetchLivres();
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to add book')),
                        );
                      }
                    },
                    child: Text('Ajouter'),
                  ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        );
      },
    );
  }

  Future<void> updateLivre(BuildContext context, Map<String, dynamic> livre) {
    TextEditingController titleController = TextEditingController(text: livre['titre']);
    TextEditingController authorController = TextEditingController(text: livre['auteur']);
    TextEditingController descriptionController = TextEditingController(text: livre['description']);
    TextEditingController priceController = TextEditingController(text: livre['prixParJour'].toString());
    TextEditingController copiesController = TextEditingController(text: livre['nombreExemplaires'].toString());
    TextEditingController availableController = TextEditingController(text: livre['exemplairesDisponibles'].toString());
    String? selectedCatalogueId = livre['catalogue']['id'].toString();

    return showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<dynamic>>(
          future: fetchCatalogues(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(content: Center(child: CircularProgressIndicator()));
            } else if (snapshot.hasError) {
              return AlertDialog(content: Text('Failed to load catalogues'));
            } else if (snapshot.hasData) {
              final catalogues = snapshot.data!;
              return AlertDialog(
                title: Text(''),
                content: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(labelText: 'Titre'),
                      ),
                      TextField(
                        controller: authorController,
                        decoration: InputDecoration(labelText: 'Auteur'),
                      ),
                      TextField(
                        controller: descriptionController,
                        decoration: InputDecoration(labelText: 'Description'),
                      ),
                      TextField(
                        controller: priceController,
                        decoration: InputDecoration(labelText: 'Prix Par Jour'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: copiesController,
                        decoration: InputDecoration(labelText: 'Nombre Exemplaires'),
                        keyboardType: TextInputType.number,
                      ),
                      TextField(
                        controller: availableController,
                        decoration: InputDecoration(labelText: 'Exemplaires Disponibles'),
                        keyboardType: TextInputType.number,
                      ),
                      DropdownButton<String>(
                        value: selectedCatalogueId,
                        hint: Text('Select Catalogue'),
                        onChanged: (value) {
                          setState(() {
                            selectedCatalogueId = value;
                          });
                        },
                        items: catalogues.map<DropdownMenuItem<String>>((catalogue) {
                          return DropdownMenuItem(
                            value: catalogue['id'].toString(),
                            child: Text(catalogue['nom']),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () async {
                      if (selectedCatalogueId == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Veuillez sélectionner un catalogue')),
                        );
                        return;
                      }

                      final updatedLivre = {
                        'titre': titleController.text,
                        'auteur': authorController.text,
                        'description': descriptionController.text,
                        'prixParJour': double.parse(priceController.text),
                        'nombreExemplaires': int.parse(copiesController.text),
                        'exemplairesDisponibles': int.parse(availableController.text),
                        'catalogue': {'id': int.parse(selectedCatalogueId!)},
                      };

                      final response = await http.put(
                        Uri.parse('http://localhost:8085/livre/${livre['id']}'),
                        headers: {'Content-Type': 'application/json'},
                        body: json.encode(updatedLivre),
                      );

                      if (response.statusCode == 200) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Book updated successfully')),
                        );
                        setState(() {
                          livresFuture = fetchLivres();
                        });
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to update book')),
                        );
                      }
                    },
                    child: Text('Update'),
                  ),
                ],
              );
            }
            return SizedBox.shrink();
          },
        );
      },
    );
  }

  Future<void> deleteLivre(int livreId) async {
    final response = await http.delete(Uri.parse('http://localhost:8085/livre/$livreId'));

    if (response.statusCode == 204) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Livre supprimé avec succès')));
      setState(() {
        livresFuture = fetchLivres();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to delete book')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: livresFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Failed to load books'));
          } else if (snapshot.hasData) {
            final livres = snapshot.data!;
            return ListView.builder(
              itemCount: livres.length,
              itemBuilder: (context, index) {
                final livre = livres[index];
                return ListTile(
                  title: Text(livre['titre']),
                  subtitle: Text('Author: ${livre['auteur']}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.grey),
                        onPressed: () => updateLivre(context, livre),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.grey),
                        onPressed: () => deleteLivre(livre['id']),
                      ),
                    ],
                  ),
                );
              },
            );
          }
          return Center(child: Text('Aucun livre trouvé'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => addLivre(context),
        child: Icon(Icons.add),
      ),
    );
  }
}
