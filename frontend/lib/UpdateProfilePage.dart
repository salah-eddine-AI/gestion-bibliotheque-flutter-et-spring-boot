import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UpdateProfilePage extends StatefulWidget {
  final int userId;

  const UpdateProfilePage({Key? key, required this.userId}) : super(key: key);

  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';
  late String _role;
  late int _nbrEmpruntRetarder;
  late int _statisticNbrEmpruntTotal;

  Future<void> fetchUserInfo() async {
    final response = await http.get(Uri.parse('http://localhost:8085/utilisateur/${widget.userId}'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      _nameController.text = data['nom'];
      _emailController.text = data['email'];
      _passwordController.text = data['motDePasse'];
      _role = data['role'];
      _nbrEmpruntRetarder = data['nbrEmpruntRetarder'];
      _statisticNbrEmpruntTotal = data['statisticNbrEmpruntTotal'];
    } else {
      setState(() {
        _errorMessage = 'Failed to load user data';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
  }

  Future<void> updateProfile() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.put(
        Uri.parse('http://localhost:8085/utilisateur/update/${widget.userId}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nom': _nameController.text,
          'email': _emailController.text,
          'motDePasse': _passwordController.text,
          'role': _role,
          'nbrEmpruntRetarder': _nbrEmpruntRetarder,
          'statisticNbrEmpruntTotal': _statisticNbrEmpruntTotal
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context);
      } else {
        setState(() {
          _errorMessage = 'Failed to update profile';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to connect to the server';
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
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
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
                    onPressed: updateProfile,
                    child: Text('Update Profile'),
                  ),
          ],
        ),
      ),
    );
  }
}
