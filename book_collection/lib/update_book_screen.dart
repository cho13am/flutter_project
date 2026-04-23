import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'books_screen.dart';
import 'new_book_screen.dart';

class UpdateBookPage extends StatefulWidget {
  final int id; //Add an ID field

  const UpdateBookPage({super.key, required this.id});

  @override
  State<StatefulWidget> createState() {
    return _UpdateBookPageState();
  }
}

class _UpdateBookPageState extends State<UpdateBookPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageurlController = TextEditingController();
  String? _selectedCategory;
  String? _selectedStatus;
  final List<String> _categories = ['Fiction', 'Non-Fiction', 'Textbooks', 'Self-Development', 'Comics / Manga'];
  final List<String> _statuses = ['Want to read', 'Reading','Finished'];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    final url = Uri.parse('https://book-api-final.vercel.app/books/${widget.id}');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final bookData = jsonDecode(response.body);
      _loadBookData(bookData);
    } else {
      _showSnackBar('Failed to fetch book data');
    }
  }
  
  void _loadBookData(Map<String, dynamic> bookData) {
    _titleController.text = bookData['title'] ?? '';
    _authorController.text = bookData['author'] ?? '';
    _imageurlController.text = bookData['image_url'] ?? '';

    _selectedCategory = _categories.contains(bookData['category'])
      ? bookData['category']
      : null;

    _selectedStatus = _statuses.contains(bookData['status'])
      ? bookData['status']
      : null;

    setState(() {});
  }

  Future<void> _update() async {
  final url = Uri.parse('https://book-api-final.vercel.app/books/');
  
  final headers = {'Content-Type': 'application/json'};
  final body = jsonEncode({
    'title': _titleController.text,
    'author': _authorController.text,
    'category': _selectedCategory ?? 'Fiction',
    'status': _selectedStatus ?? 'Want to read',
    'image_url': _imageurlController.text,
    'id': widget.id,
  });

    try {
      final response = await http.put(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update Successful!')),
      );
      Navigator.pop(context, true);
    } else {
      print('Status Code: ${response.statusCode}');
      print('Response: ${response.body}');
      if(mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Update Failed!')),
      );
      }
    }
  } catch (e) {
    print('Error: $e');
  }
}

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 2),
    ));
  }

@override
Widget build(BuildContext context) {
  return GestureDetector(
    onTap: () => FocusScope.of(context).unfocus(),
    child: Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Text('Edit Book',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => NewBookPage())
                      );
                    },
                  ),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextField(_titleController, 'Title', Icons.book_outlined),
                      const SizedBox(height: 20),
                      _buildTextField(_authorController, 'Author', Icons.person_outline),
                      const SizedBox(height: 20),
                      
                      DropdownButtonFormField<String>(
                        value: _selectedCategory,
                        decoration: InputDecoration(
                          labelText: 'Category',
                          prefixIcon: const Icon(Icons.category_outlined),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        items: _categories.map((String category) {
                          return DropdownMenuItem(value: category, child: Text(category));
                        }).toList(),
                        onChanged: (val) => setState(() => _selectedCategory = val),
                      ),
                      
                      const SizedBox(height: 25),
                      const Text("Status", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: ['Want to read', 'Reading', 'Finished'].map((status) {
                            return RadioListTile<String>(
                              controlAffinity: ListTileControlAffinity.leading,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                              title: Text(status),
                              value: status,
                              groupValue: _selectedStatus,
                              activeColor: Colors.black,
                              onChanged: (value) => setState(() => _selectedStatus = value),
                            );
                          }).toList(),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      _buildTextField(_imageurlController, 'Image URL', Icons.link),
                      
                      const SizedBox(height: 40),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: _update,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
  return TextFormField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 2),
      ),
    ),
    validator: (value) => (value == null || value.isEmpty) ? 'Please enter $label' : null,
  );
}
}