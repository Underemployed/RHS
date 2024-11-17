import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class RHSScreen extends StatefulWidget {
  const RHSScreen({super.key});

  @override
  State<RHSScreen> createState() => _RHSScreenState();
}

class _RHSScreenState extends State<RHSScreen> {
  List<List<dynamic>> _data = [];
  List<List<dynamic>> _filteredData = [];
  List<String> _headers = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    final rawData = await rootBundle.loadString("assets/data/mydata.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    setState(() {
      // First row is headers
      _headers = listData[0].map((header) => header.toString().trim()).toList();

      // Data starts from second row
      _data = listData;
      _filteredData = listData.sublist(1);
    });
  }

  void _search_result(String query) {
    setState(() {
      // If query is a valid integer, search by first column (typically ID)
      if (int.tryParse(query) != null) {
        _filteredData = _data.sublist(1).where((row) {
          return row[0].toString() == query;
        }).toList();
      }
      // Otherwise, search by name column (assuming second column is name)
      else {
        _filteredData = _data.sublist(1).where((row) {
          return row[1].toString().toLowerCase().contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("RHS Search"),
      ),
      body: _headers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by ${_headers[0]} or ${_headers[1]}',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _search_result,
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _filteredData.length,
                    itemBuilder: (_, index) {
                      return Card(
                        margin: const EdgeInsets.all(3),
                        child: ListTile(
                          title: Text(
                              '${_filteredData[index][0]} - ${_filteredData[index][1]}'),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PersonDetailScreen(
                                    personData: _filteredData[index],
                                    headers: _headers),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class PersonDetailScreen extends StatelessWidget {
  final List<dynamic> personData;
  final List<String> headers;

  const PersonDetailScreen(
      {Key? key, required this.personData, required this.headers})
      : super(key: key);

  // convert Google Drive sharing link to direct image link
  String _convertDriveImageLink(String driveLink) {
    try {
      //  file ID from drive link
      RegExp regExp = RegExp(r'/d/([^/]+)/');
      Match? match = regExp.firstMatch(driveLink);

      if (match != null) {
        String fileId = match.group(1)!;
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    } catch (e) {
      print('Error converting drive link: $e');
    }

    return driveLink; // Return original link if conversion fails
  }

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: headers.length,
          itemBuilder: (context, index) {
            String label = headers[index];
            String value = personData[index].toString();

            // check image is drive link
            bool isPotentialImageLink = value.contains('drive.google.com') &&
                value.contains('/d/') &&
                value.contains('view?usp=sharing');

            return Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 1,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: isPotentialImageLink
                          ? GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImage(
                                      imageUrl: _convertDriveImageLink(value),
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: value,
                                child: Image.network(
                                  _convertDriveImageLink(value),
                                  height: 50,
                                  fit: BoxFit.contain,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  },
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.error);
                                  },
                                ),
                              ),
                            )
                          : Text(
                              value,
                              style: TextStyle(fontSize: 14),
                            ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class FullScreenImage extends StatelessWidget {
  final String imageUrl;

  const FullScreenImage({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Hero(
          tag: imageUrl,
          child: InteractiveViewer(
            child: Image.network(
              imageUrl,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Center(
                  child: CircularProgressIndicator(),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Icon(Icons.error, color: Colors.white);
              },
            ),
          ),
        ),
      ),
    );
  }
}
