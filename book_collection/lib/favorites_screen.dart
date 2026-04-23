import 'package:book_collection/books_screen.dart';
import 'package:flutter/material.dart';
import 'book_detail_screen.dart';

class FavoritesPage extends StatefulWidget {
  final List<dynamic> books; //parameter
  final Set<int> favoriteIds;

  const FavoritesPage({super.key, required this.books, required this.favoriteIds});

  @override
  State<StatefulWidget> createState() {
    return _FavoritesPageState();
  }
}

class _FavoritesPageState extends State<FavoritesPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              child: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios_new),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text('My Favorites', 
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                  Icon(Icons.favorite, color: Colors.red),
                ],
              ),
            ),
            Expanded(
              child: widget.books.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    itemCount: widget.books.length,
                    itemBuilder: (context, index) {
                      final book = widget.books[index];
                      return _buildFavoriteCard(context, book);
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoriteCard(BuildContext context, dynamic book) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 225, 238, 245),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            book['image_url'],
            width: 60,
            height: 90,
            fit: BoxFit.cover,
          ),
        ),
        title: Text(
          book['title'],
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book['author'], style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 5),
            Text(
              book['status'],
              style: const TextStyle(color: Colors.black, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => BookDetailPage(
                id: book['id'], 
                favoriteIds: widget.favoriteIds,
              ),
            ),
          ).then((_) {
            setState(() {});
          });
        },
      ),
    );
  }
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No favorites yet',
            style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}