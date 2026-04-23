import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class NewBookPage extends StatefulWidget {
  const NewBookPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewBookPageState();
  }
}

class _NewBookPageState extends State<NewBookPage> {
  final _formKey =GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _authorController = TextEditingController();
  final TextEditingController _imageurlController = TextEditingController();
  String? _selectedCategory;
  String? _selectedStatus = 'Want to read';
  final List<String> _categories = ['Fiction', 'Non-Fiction', 'Textbooks', 'Self-Development', 'Comics / Manga'];
  //final List<String> _statuses = ['Want to read', 'Reading','Finished'];

  Future<void> _newBook() async {
    if(_formKey.currentState!.validate()) {
      final url = Uri.parse('https://book-api-final.vercel.app/books/');
      final response = await http.post(
        url, 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': _titleController.text,
          'author': _authorController.text,
          'category': _selectedCategory,
          'status': _selectedStatus,
          'image_url': _imageurlController.text,
        }),
      );
      if(mounted && (response.statusCode == 200 || response.statusCode == 201)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Add new book successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    }
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
                          icon: const Icon(Icons.arrow_back_ios_new),
                          onPressed: () => Navigator.pop(context), 
                        ),
                        const Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(right: 30),
                            child: Text('New Book',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    )
                  ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTextField(_titleController, 'Book Title', Icons.book_outlined),
                        const SizedBox(height: 20),
                        _buildTextField(_authorController, 'Author Name', Icons.person_outline),
                        const SizedBox(height: 20),
                        
                        DropdownButtonFormField<String>(
                          value: _selectedCategory,
                          decoration: InputDecoration(
                            labelText: 'Category',
                            prefixIcon: const Icon(Icons.category_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (val) => setState(() => _selectedCategory = val),
                          validator: (value) => value == null ? 'Please select category' : null,
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
                            onPressed: _newBook,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Text('Add to Collection', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
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
      validator: (value) => (value == null || value.isEmpty) ? 'Required field' : null,
    );
  }
}