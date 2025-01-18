import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpruntPage extends StatefulWidget {
  final int livreId;
  final int userId;

  const EmpruntPage({Key? key, required this.livreId, required this.userId}) : super(key: key);

  @override
  _EmpruntPageState createState() => _EmpruntPageState();
}

class _EmpruntPageState extends State<EmpruntPage> {
  DateTime? _selectedDateRetour; 
  DateTime _currentDate = DateTime.now();
  bool _isSubmitting = false;

  
  Future<void> _selectDateRetour(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _currentDate.add(Duration(days: 1)), 
      firstDate: _currentDate.add(Duration(days: 1)), 
      lastDate: DateTime(2101), 
    );
    if (picked != null && picked != _selectedDateRetour) {
      setState(() {
        _selectedDateRetour = picked;
      });
    }
  }

  Future<void> _submitEmprunt() async {
    if (_selectedDateRetour == null) {
      
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('selectionner la date de retour')));
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    final empruntData = {
      "dateEmprunt": _currentDate.toIso8601String(),
      "dateRetour": _selectedDateRetour!.toIso8601String(),
      "empruntStatus": "ENCOURS",
      "utilisateur": {
        "id": widget.userId, 
      },
      "livre": {
        "id": widget.livreId, 
      },
    };

    try {
      final response = await http.post(
        Uri.parse('http://localhost:8085/emprunt'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(empruntData),
      );

      if (response.statusCode == 201) {
       
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Livre emprunté avec succès !')));
        Navigator.pop(context);
      } else {
     
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to borrow the book')));
      }
    } catch (e) {
    
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isSubmitting = false;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           /* Text('Livre ID: ${widget.livreId}'),
            Text('User ID: ${widget.userId}'),*/
            SizedBox(height: 20),
           
            Text(
              'Current Date: ${_currentDate.toLocal().toString().split(' ')[0]}', 
            ),
            SizedBox(height: 20),
            
            Row(
              children: [
                Text('Date de retour: '),
                Text(
                  _selectedDateRetour == null
                      ? 'Not Selected'
                      : _selectedDateRetour!.toLocal().toString().split(' ')[0],
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () => _selectDateRetour(context),
                ),
              ],
            ),
            SizedBox(height: 20),
           
            ElevatedButton(
              onPressed: _isSubmitting ? null : _submitEmprunt,
              child: _isSubmitting
                  ? CircularProgressIndicator()
                  : Text('Valider'), 
            ),
          ],
        ),
      ),
    );
  }
}
