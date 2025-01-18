import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'User.dart'; 
import 'Book.dart'; 

class StatisticsPage extends StatefulWidget {
  const StatisticsPage({Key? key}) : super(key: key);

  @override
  _StatisticsPageState createState() => _StatisticsPageState();
}

class _StatisticsPageState extends State<StatisticsPage> {
  List<User> users = [];
  List<Book> books = [];
  bool isLoading = false;  
  bool isUsersLoaded = false; 
  bool isBooksLoaded = false;  
  
  Future<void> fetchUsers() async {
    setState(() {
      isLoading = true; 
      users.clear(); 
      books.clear(); 
    });

    final response = await http.get(Uri.parse('http://localhost:8085/utilisateur/all'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      setState(() {
        users = data
            .map((userJson) => User.fromJson(userJson))
            .where((user) => user.role == 'UTILISATEUR')
            .toList()
            ..sort((a, b) => b.statisticNbrEmpruntTotal.compareTo(a.statisticNbrEmpruntTotal)); // Sort by statisticNbrEmpruntTotal descending
        isLoading = false; 
        isUsersLoaded = true; 
        isBooksLoaded = false; 
      });
    } else {
      setState(() {
        isLoading = false;
      });
     
      throw Exception('Failed to load users');
    }
  }

  
  Future<void> fetchBooks() async {
    setState(() {
      isLoading = true;  
      books.clear(); 
      users.clear(); 
    });

    final response = await http.get(Uri.parse('http://localhost:8085/livre'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);

      setState(() {
        books = data
            .map((bookJson) => Book.fromJson(bookJson))
            .toList()
            ..sort((a, b) => b.statisticNbrEmpruntTotal.compareTo(a.statisticNbrEmpruntTotal)); // Sort by statisticNbrEmpruntTotal descending
        isLoading = false; 
        isBooksLoaded = true; 
        isUsersLoaded = false; 
      });
    } else {
      setState(() {
        isLoading = false;
      });
      
      throw Exception('Failed to load books');
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            ElevatedButton(
              onPressed: fetchUsers, 
              child: Text('Les utilisateurs les plus actifs'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: fetchBooks, 
              child: Text('Les livres les plus empruntés'),
            ),
            SizedBox(height: 20),
            if (isLoading) 
              CircularProgressIndicator(),
            if (!isLoading && isUsersLoaded) 
              Expanded(
                child: ListView.builder(
                  itemCount: users.length,
                  itemBuilder: (context, index) {
                    final user = users[index];
                    return ListTile(
                      title: Text(user.nom),
                      subtitle: Text('Email: ${user.email}\nEmprunts Retardés: ${user.nbrEmpruntRetarder}\nEmprunts Totaux: ${user.statisticNbrEmpruntTotal}'),
                    );
                  },
                ),
              ),
            if (!isLoading && isBooksLoaded) 
              Expanded(
                child: ListView.builder(
                  itemCount: books.length,
                  itemBuilder: (context, index) {
                    final book = books[index];
                    return ListTile(
                      title: Text(book.titre),
                      subtitle: Text(
                        'Auteur: ${book.auteur}\n'
                        'Description: ${book.description}\n'
                        'Prix Par Jour: ${book.prixParJour}\n'
                        'Emprunts Totaux: ${book.statisticNbrEmpruntTotal}\n'
                        'Catalogue: ${book.catalogueNom}',
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
