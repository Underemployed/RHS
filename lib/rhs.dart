import 'package:excel/excel.dart';
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
    _loadExcel();
  }

  void _loadExcel() async {
    final bytes = await rootBundle.load('assets/data/rhs.xlsx');
    final excel = Excel.decodeBytes(bytes.buffer.asUint8List());

    var sheet = excel.tables[excel.tables.keys.first];
    List<List<dynamic>> listData = [];

    for (var row in sheet!.rows) {
      listData.add(row.map((cell) {
        var value = cell?.value ?? '';
        if (value is double) {
          return value.toInt();
        }
        return value;
      }).toList());
    }

    setState(() {
      _headers = listData[0].map((header) => header.toString().trim()).toList();
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

  // Function to convert Google Drive sharing link to direct image link
  String _convertDriveImageLink(String driveLink) {
    try {
      RegExp regExp = RegExp(r'/d/([^/]+)/');
      Match? match = regExp.firstMatch(driveLink);

      if (match != null) {
        String fileId = match.group(1)!;
        return 'https://drive.google.com/uc?export=view&id=$fileId';
      }
    } catch (e) {
      print('Error converting drive link: $e');
    }

    return driveLink;
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Table(
            border: TableBorder.all(color: Colors.grey.shade300),
            columnWidths: {
              0: FlexColumnWidth(1),
              1: FlexColumnWidth(2),
            },
            children: [
              // Generate table rows dynamically
              for (int i = 0; i < headers.length; i++)
                TableRow(
                  decoration: BoxDecoration(
                      color: i % 2 == 0 ? Colors.grey.shade100 : Colors.white),
                  children: [
                    // Header column
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        headers[i],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    // Value column
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _buildDetailCell(headers[i], personData[i]),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailCell(String header, dynamic value) {
    // Check for image link
    bool isPotentialImageLink = value.toString().contains('drive.google.com') &&
        value.toString().contains('/d/') &&
        value.toString().contains('view');

    // Check for map link
    bool isMapLink = value.toString().contains(
        RegExp(r'maps\.app\.goo\.gl|maps\.google|map.*google|local\.google'));

    // If it's an image link
    if (isPotentialImageLink) {
      return GestureDetector(
        onTap: () => _launchURL(value.toString()),
        child: Image.network(
          _convertDriveImageLink(value.toString()),
          fit: BoxFit.fitWidth,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return CircularProgressIndicator();
          },
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.error);
          },
        ),
      );
    }

    // If it's a map link
    if (isMapLink) {
      return GestureDetector(
        onTap: () => _launchURL(value.toString()),
        child: Row(
          children: [
            Icon(Icons.map, color: Colors.blue),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Open Location',
                style: TextStyle(
                    color: Colors.blue, decoration: TextDecoration.underline),
              ),
            ),
          ],
        ),
      );
    }

    // Default text display
    return Text(value.toString());
  }
}
