import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> login(String email, String password) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8085/utilisateur/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        String role = data['role'];
        int id = data['id'];

        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setInt('userId', id);

        if (role == 'UTILISATEUR') {
          Navigator.pushReplacementNamed(context, '/userPage', arguments: id);
        } else if (role == 'BIBLIOTHECAIRE') {
          Navigator.pushReplacementNamed(context, '/adminPage', arguments: id);
        }
      } else if (response.statusCode == 404) {
        setState(() {
          _errorMessage = 'Email ou mot de passe invalide.';
        });
      } else {
        setState(() {
          _errorMessage = 'An unexpected error occurred.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to the server.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> signUp(String nom, String email, String password, String role) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8085/utilisateur/save'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': nom,
          'email': email,
          'motDePasse': password,
          'role': role
        }),
      );

      if (response.statusCode == 201) {
        
        Navigator.pop(context); 

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User successfully registered!')));

        Navigator.pushReplacementNamed(context, '/login');
      } else if (response.statusCode == 409) {
       
        setState(() {
          _errorMessage = 'Email is already in use.';
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to register the user.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = '';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: TextStyle(color: Colors.red)),
            SizedBox(height: 16),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      String email = _emailController.text.trim();
                      String password = _passwordController.text.trim();
                      login(email, password);
                    },
                    child: Text('Login'),
                  ),
            SizedBox(height: 16),
            
            TextButton(
              onPressed: () => _showSignUpDialog(context),
              child: Text('Sign Up'),
            ),
          ],
        ),
      ),
    );
  }

  
  void _showSignUpDialog(BuildContext context) {
    final TextEditingController _nomController = TextEditingController();
    final TextEditingController _emailController = TextEditingController();
    final TextEditingController _passwordController = TextEditingController();
    String selectedRole = 'UTILISATEUR'; // Default role

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(''),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nomController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              DropdownButton<String>(
                value: selectedRole,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedRole = newValue!;
                  });
                },
                items: <String>['UTILISATEUR', 'BIBLIOTHECAIRE']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                String nom = _nomController.text.trim();
                String email = _emailController.text.trim();
                String password = _passwordController.text.trim();
                signUp(nom, email, password, selectedRole);
              },
              child: Text('Sign Up'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); 
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }
}
