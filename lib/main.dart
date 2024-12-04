import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() {
  runApp(CartoonApp());
}

class CartoonApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cartoon App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: HomePage(),
    );
  }
}

// Home Page
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> cartoons = [];
  List<dynamic> filteredCartoons = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCartoons();
  }

  Future<void> fetchCartoons() async {
    final response = await http.get(
      Uri.parse('https://api.sampleapis.com/cartoons/cartoons2D'),
    );

    if (response.statusCode == 200) {
      setState(() {
        cartoons = json.decode(response.body);
        filteredCartoons = cartoons;
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
      throw Exception('Failed to load cartoons');
    }
  }

  void searchCartoons(String query) {
    setState(() {
      filteredCartoons = cartoons
          .where((cartoon) => cartoon['title']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cartoon Collection'),
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => GenrePage(cartoons: cartoons)),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade200, Colors.blue.shade900],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(10),
              child: TextField(
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  labelText: 'Search',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: searchCartoons,
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: filteredCartoons.length,
                      itemBuilder: (context, index) {
                        var cartoon = filteredCartoons[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                            elevation: 5,
                            child: ListTile(
                              contentPadding: EdgeInsets.all(10),
                              leading: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.network(
                                  cartoon['image'] ?? '',
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(Icons.error, size: 50),
                                ),
                              ),
                              title: Text(
                                cartoon['title'] ?? 'Unknown',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Text(
                                cartoon['year']?.toString() ??
                                    'Year not available',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        CartoonDetailPage(cartoon: cartoon),
                                  ),
                                );
                              },
                            ),
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

// Genre Page
class GenrePage extends StatelessWidget {
  final List<dynamic> cartoons;

  GenrePage({required this.cartoons});

  @override
  Widget build(BuildContext context) {
    Map<String, List<dynamic>> genres = {};

    for (var cartoon in cartoons) {
      if (cartoon['genre'] != null) {
        for (var genre in cartoon['genre']) {
          if (!genres.containsKey(genre)) {
            genres[genre] = [];
          }
          genres[genre]!.add(cartoon);
        }
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Cartoons by Genre'),
      ),
      body: ListView(
        children: genres.keys.map((genre) {
          return Card(
            margin: EdgeInsets.all(10),
            child: ListTile(
              title: Text(genre),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GenreCartoonsPage(
                      genre: genre,
                      cartoons: genres[genre]!,
                    ),
                  ),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}

// Cartoons by Genre Page
class GenreCartoonsPage extends StatelessWidget {
  final String genre;
  final List<dynamic> cartoons;

  GenreCartoonsPage({required this.genre, required this.cartoons});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$genre Cartoons'),
        backgroundColor: Colors.blueAccent, // Custom app bar color
      ),
      body: cartoons.isEmpty
          ? Center(
              child: Text(
                'No cartoons available for $genre',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Custom Header for Genre Page
                  Container(
                    color: Colors.blueAccent,
                    width: double.infinity,
                    padding: EdgeInsets.all(16),
                    child: Text(
                      'Explore the Best Cartoons in $genre!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  // Displaying Cartoon List
                  ListView.builder(
                    shrinkWrap:
                        true, // Ensures the list fits within the available space
                    physics:
                        NeverScrollableScrollPhysics(), // Disables scrolling for nested ListView
                    itemCount: cartoons.length,
                    itemBuilder: (context, index) {
                      var cartoon = cartoons[index];
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 10,
                          shadowColor: Colors.black26,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CartoonDetailPage(cartoon: cartoon),
                                ),
                              );
                            },
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: Row(
                                children: [
                                  // Cartoon Image
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(
                                      cartoon['image'] ??
                                          'https://via.placeholder.com/100',
                                      width: 100,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) =>
                                              Icon(Icons.error, size: 50),
                                    ),
                                  ),
                                  // Cartoon Title and Year
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            cartoon['title'] ?? 'Unknown',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                            ),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            cartoon['year']?.toString() ??
                                                'Year not available',
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}

// Cartoon Detail Page
class CartoonDetailPage extends StatelessWidget {
  final dynamic cartoon;

  CartoonDetailPage({required this.cartoon});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(cartoon['title'] ?? 'Unknown Cartoon'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.network(
                cartoon['image'] ?? 'https://via.placeholder.com/300',
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.error, size: 100),
              ),
              SizedBox(height: 16),
              Text(
                cartoon['title'] ?? 'Unknown',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('Year: ${cartoon['year'] ?? 'Not available'}'),
              SizedBox(height: 16),
              Text(
                'Description: ${cartoon['description'] ?? 'No description available'}',
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
