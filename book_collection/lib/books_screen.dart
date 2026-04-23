import 'package:book_collection/book_detail_screen.dart';
import 'package:book_collection/new_book_screen.dart';
import 'package:book_collection/favorites_screen.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BooksPage extends StatefulWidget {
  const BooksPage({super.key});

  @override
  State<StatefulWidget> createState() {
    return _BooksPageState();
  }
}

class _BooksPageState extends State<BooksPage> {
  List<dynamic> _books = [];
  final Set<int> _favoriteIds = {};
  List<dynamic> _filteredBooks = [];
  String _searchQuery = "";
  int _selectedIndex = 0;

  void _searchBooks(String query) {
    setState(() {
    _searchQuery = query;
    _filteredBooks = _books.where((book) {
      final title = book['title'].toString().toLowerCase();
      final author = book['author'].toString().toLowerCase();
      final category = book['category'].toString().toLowerCase();
      final searchLower = query.toLowerCase();
      
      return title.contains(searchLower) || 
             author.contains(searchLower) || 
             category.contains(searchLower);
    }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
  final response = await http.get(Uri.parse('https://learning-flutter.vercel.app/books'));

    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);

      if (mounted) {
        setState(() {
          if (decodedData is List) {
            _books = decodedData;
            _filteredBooks = decodedData;
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), //กดจอเปล่า เคอร์เซอร์ตรง SearchBar จะหายไป
      child: Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Book Collection',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w500),
                  ),

                  SizedBox(
                    width: 160,
                    height: 30,
                    child: SearchBar(
                      backgroundColor: WidgetStateProperty.all(const Color.fromARGB(255, 246, 237, 237)),
                      leading: const Icon(Icons.search),
                      onChanged: (value) => _searchBooks(value),
                      hintText: 'Search',
                      elevation: WidgetStateProperty.all(0),
                    ),
                  ),
                ],
              ),
            )
          ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.zero, //ช่วยให้ลิสต์ไม่ห่างเกินไป
              itemCount: _filteredBooks.length,
              itemBuilder: (context, index) {
                final book = _filteredBooks[index];
                return Card(
                  color: Color.fromARGB(255, 225, 238, 245),
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), //เพิ่มระยะห่างรอบตัว Card
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.2,
                      child: Image.network(book['image_url']),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        _favoriteIds.contains(book['id'])
                        ? Icons.favorite //กดแล้วจะเป็นรูปหัวใจเต็ม
                        : Icons.favorite_border //ยังไม่กด จะเป็น outlined
                      ),
                      onPressed: () {
                        if(mounted) {
                          setState(() {
                            if(_favoriteIds.contains(book['id'])) {
                              _favoriteIds.remove(book['id']);
                            } else {
                              _favoriteIds.add(book['id']);
                            }
                          });
                        }
                      },
                    ),
                    title: Text(book['title'],
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(book['author'],
                          style: TextStyle(color: Colors.grey[600]),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 5),
                        Text(book['status'],
                          style: TextStyle(fontSize: 12, color: Colors.black ,fontWeight: FontWeight.bold),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context, MaterialPageRoute(
                          builder: (context) => BookDetailPage(
                            id: book['id'],
                            favoriteIds: _favoriteIds,
                          ),
                        ),
                      ).then((_) {
                        _fetchBooks();
                      });
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),

      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (int index) async {
          if(mounted) {
            setState(() {
              _selectedIndex = index; //update หน้าที่เลือก
            });
            if(index == 1) {
              final result = await Navigator.push(context, MaterialPageRoute(
                builder: (context) => const NewBookPage())
              );
                if (result == true) {
                  _fetchBooks();
                }
                setState(() {
                  _selectedIndex = 0;
                });
            } else if (index == 2) {
              await Navigator.push(context, MaterialPageRoute(
                builder: (context) => FavoritesPage(
                  books: _books.where((b) => _favoriteIds.contains(b['id'])).toList(),
                  favoriteIds: _favoriteIds,
                ),
              ),
              ).then((_) {
                setState(() {
                  _selectedIndex = 0;
                });
              });
            }
          }
        },

        height: 60,
        backgroundColor: Colors.white,
        destinations: [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home'),
          NavigationDestination(
            icon: Icon(Icons.add_outlined),
            selectedIcon: Icon(Icons.add_rounded),
            label: 'New'),
          NavigationDestination(
            icon: Icon(Icons.favorite_border_rounded),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favorites'),
        ]),
      ),
    );
  }
}