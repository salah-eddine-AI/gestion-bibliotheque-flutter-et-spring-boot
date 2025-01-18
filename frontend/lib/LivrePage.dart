import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'empruntPage.dart';

class LivrePage extends StatefulWidget {
  final int userId;

  const LivrePage({Key? key, required this.userId}) : super(key: key);

  @override
  _LivrePageState createState() => _LivrePageState();
}

class _LivrePageState extends State<LivrePage> {
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  List<dynamic> _books = [];
  List<dynamic> _categories = [];
  String _searchType = 'author';
  String _selectedCategory = '';

  Future<void> fetchBooks({String? query}) async {
    setState(() {
      _isLoading = true;
    });

    String url = 'http://localhost:8085/livre';
    if (query != null && query.isNotEmpty) {
      if (_searchType == 'author') {
        url = 'http://localhost:8085/livre/getlivresbyauteur?auteur=$query';
      } else if (_searchType == 'title') {
        url = 'http://localhost:8085/livre/getlivresbytitre?titre=$query';
      }
    }
    if (_selectedCategory.isNotEmpty && _selectedCategory != 'All') {
      url = 'http://localhost:8085/livre/getlivresbycatalogue?catalogue=$_selectedCategory';
    }

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        setState(() {
          _books = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load books');
      }
    } catch (e) {
      print(e);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('http://localhost:8085/catalogue'));
      if (response.statusCode == 200) {
        setState(() {
          _categories = json.decode(response.body);
        });
      } else {
        throw Exception('Failed to load categories');
      }
    } catch (e) {
      print(e);
    }
  }

 Future<void> fetchRecommendations(String query) async {
  try {
    final response = await http.post(
      Uri.parse('http://localhost:8081/query'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'query': query}),
    );
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      _showRecommendationDialog(responseData);
    } else {
      _showErrorMessage("Sorry, I couldn't understand your query.");
    }
  } catch (e) {
    print(e);
    _showErrorMessage("Sorry, I couldn't understand your query.");
  }
}

void _showErrorMessage(String message) {
  // Displaying an error message to the user
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Error'),
      content: Text(message),
      actions: <Widget>[
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
          },
          child: Text('OK'),
        ),
      ],
    ),
  );
}


  void _showRecommendationDialog(List<dynamic> recommendations) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Book Recommendations'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: recommendations.map<Widget>((book) {
              return Text('Title: ${book['titre']}, Author: ${book['auteur']}');
            }).toList(),
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    fetchBooks();
    fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Livre Page')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(labelText: 'Search'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    fetchBooks(query: _searchController.text.trim());
                  },
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Radio<String>(
                          value: 'author',
                          groupValue: _searchType,
                          onChanged: (value) {
                            setState(() {
                              _searchType = value!;
                            });
                          },
                        ),
                        Text('Auteure'),
                        Radio<String>(
                          value: 'title',
                          groupValue: _searchType,
                          onChanged: (value) {
                            setState(() {
                              _searchType = value!;
                            });
                          },
                        ),
                        Text('Titre'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Text('Category: '),
                DropdownButton<String>(
                  value: _selectedCategory.isEmpty ? null : _selectedCategory,
                  hint: Text('Select Category'),
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                    fetchBooks();
                  },
                  items: [
                    DropdownMenuItem<String>(
                      value: 'All',
                      child: Text('All'),
                    ),
                    ..._categories.map<DropdownMenuItem<String>>((dynamic category) {
                      return DropdownMenuItem<String>(
                        value: category['nom'],
                        child: Text(category['nom']),
                      );
                    }).toList(),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView.builder(
                      itemCount: _books.length,
                      itemBuilder: (context, index) {
                        final book = _books[index];
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 8.0),
                          elevation: 4.0,
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  book['titre'],
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 8.0),
                                Text('Auteure: ${book['auteur']}'),
                                SizedBox(height: 4.0),
                                Text('Description: ${book['description']}'),
                                SizedBox(height: 4.0),
                                Text('Prix ​​par jour: ${book['prixParJour']}'),
                                SizedBox(height: 4.0),
                                Text('Copies: ${book['nombreExemplaires']}'),
                                SizedBox(height: 4.0),
                                Text('Disponible: ${book['exemplairesDisponibles']}'),
                                SizedBox(height: 4.0),
                                Text('Total des prêts: ${book['statisticNbrEmpruntTotal']}'),
                                SizedBox(height: 8.0),
                                Text(
                                  'Catalogue: ${book['catalogue']['nom']}',
                                  style: TextStyle(fontStyle: FontStyle.italic),
                                ),
                                SizedBox(height: 8.0),
                                ElevatedButton(
                                  onPressed: () {
                                    int livreId = book['id'];
                                    int userId = widget.userId;
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EmpruntPage(
                                          livreId: livreId,
                                          userId: userId,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text('Réserver'),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                // Show query input popup
                _showQueryDialog();
              },
              child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Icon(Icons.face, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showQueryDialog() {
    TextEditingController queryController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Enter your query'),
        content: TextField(
          controller: queryController,
          decoration: InputDecoration(hintText: 'Type your query here'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              fetchRecommendations(queryController.text.trim());
            },
            child: Text('Submit'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }
}
