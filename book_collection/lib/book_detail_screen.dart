import 'package:book_collection/update_book_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BookDetailPage extends StatefulWidget {
  final int id;
  final Set<int> favoriteIds;
  const BookDetailPage({super.key, required this.id, required this.favoriteIds});

  @override
  State<StatefulWidget> createState() {
    return _BookDetailPageState();
  }
}

class _BookDetailPageState extends State<BookDetailPage> {
  Map<dynamic, dynamic>? _bookDetail;

  @override
  void initState() {
    super.initState();
    _fetchBookDetail();
  }

  Future<void> _fetchBookDetail() async {
    final response = await http.get(
      Uri.parse('https://book-api-final.vercel.app/books/${widget.id}'));
    setState(() {
      _bookDetail = json.decode(response.body);
    });
  }

  Future<void> _deleteBook() async {
    final url = Uri.parse('https://book-api-final.vercel.app/books');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'id': widget.id});

    try {
      final response = await http.delete(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pop(context, true); 
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Deleted successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        throw Exception('Failed to delete book');
      }
    } catch (e) {
      print(e);
    }
  }

  void _showDeleteConfirmation() {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this book?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('No'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteBook();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Yes'),
          ),
        ],
      );
    },
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _bookDetail == null
        ? const Center(child: CircularProgressIndicator())
        : Column(
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                child: Row(children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context), 
                  ),
                  const Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: 30),
                      child: Text('Book Detail',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (context) => UpdateBookPage(id: _bookDetail!['id']))
                      ).then((value) => _fetchBookDetail());
                    },
                  ),
                ],
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Card(
                  color: Color.fromARGB(255, 225, 238, 245),
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                        child: Image.network(_bookDetail!['image_url'],
                          height: 350,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, StackTrace) => Container(
                            height: 200,
                            color: Colors.grey,
                            child: const Icon(Icons.book_online_outlined, size: 50)
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text( _bookDetail!['category'],
                                style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(height: 15),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                child: Text( _bookDetail!['title'],
                                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                                ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    widget.favoriteIds.contains(_bookDetail!['id'])
                                    ? Icons.favorite //กดแล้วจะเป็นรูปหัวใจเต็ม
                                    : Icons.favorite_border //ยังไม่กด จะเป็น outlined
                                  ),
                                  onPressed: () {
                                    if(mounted) {
                                      setState(() {
                                        if(widget.favoriteIds.contains(_bookDetail!['id'])) {
                                          widget.favoriteIds.remove(_bookDetail!['id']);
                                        } else {
                                        widget.favoriteIds.add(_bookDetail!['id']);
                                        }
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),                        
                              ],
                            ), 

                            Text("By ${_bookDetail!['author']}",
                              style: TextStyle(fontSize: 18, color: Colors.grey[700], fontStyle: FontStyle.normal),
                            ),
                            const Divider(height: 30),
                            
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 20, color: Colors.orange),
                                const SizedBox(width: 8),
                                Text( _bookDetail!['status'] ?? 'No status',
                                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20.0),
                              child: Center(
                                child: SizedBox(
                                  width: 135,
                                  height: 30,
                                  child: ElevatedButton(
                                    onPressed: _showDeleteConfirmation,
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.red,
                                      backgroundColor: Colors.white,
                                      side: const BorderSide(color: Colors.red),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                                    ),
                                    child: const Text('Delete Book'),
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
    );
  }
}