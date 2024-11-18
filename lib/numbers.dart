import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  List<List<dynamic>> _data = [];
  List<List<dynamic>> _filteredData = [];
  Map<String, int> _headerIndices = {};
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchPerformed = false;

  // Required headers with alternative names
  final requiredHeaders = {
    'name': ['name', 'full name', 'person name', "fullname"],
    'phone': [
      'phone',
      'mobile',
      'phone number',
      'contact',
      'number',
      'contact number',
      'mobile number'
    ],
    'rank': ['rank', 'designation', 'position']
  };

  @override
  void initState() {
    super.initState();
    _loadExcel();
  }

  int? _getHeaderIndex(List<String> possibleHeaders) {
    for (var possible in possibleHeaders) {
      for (var entry in _headerIndices.entries) {
        if (entry.key.toLowerCase().trim() == possible) {
          return entry.value;
        }
      }
    }
    return null;
  }

  Future<void> _launchPhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch $phoneNumber')),
      );
    }
  }

  void _loadExcel() async {
    try {
      final bytes = await rootBundle.load("assets/data/contacts.xlsx");
      final excel = Excel.decodeBytes(bytes.buffer.asUint8List());

      var sheet = excel.tables[excel.tables.keys.first];
      if (sheet == null) {
        throw 'Excel sheet not found';
      }

      List<List<dynamic>> listData = [];

      // Process headers
      var headers = sheet.rows.first;
      for (var i = 0; i < headers.length; i++) {
        var headerValue =
            headers[i]?.value?.toString().toLowerCase().trim() ?? '';
        _headerIndices[headerValue] = i;
      }

      // Validate required headers
      var missingHeaders = [];
      for (var header in requiredHeaders.entries) {
        if (_getHeaderIndex(header.value) == null) {
          missingHeaders.add(header.key);
        }
      }

      if (missingHeaders.isNotEmpty) {
        throw 'Missing required headers: ${missingHeaders.join(", ")}';
      }

      // Process data rows
      for (var row in sheet.rows.skip(1)) {
        listData.add(row.map((cell) {
          var value = cell?.value ?? '';
          if (value is double) {
            return value.toInt();
          }
          return value;
        }).toList());
      }

      setState(() {
        _data = listData;
        _filteredData = listData;
      });
    } catch (e) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Excel Loading Error'),
          content: Text(e.toString()),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  void _performSearch() {
    String query = _searchController.text.toLowerCase().trim();
    var nameIndex = _getHeaderIndex(requiredHeaders['name']!);
    if (nameIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Name header not found in the Excel sheet')),
      );
      return;
    }

    setState(() {
      if (query.isEmpty) {
        _isSearchPerformed = false;
        _filteredData = [];
      } else {
        _filteredData = _data.where((row) {
          String name = row[nameIndex].toString().toLowerCase();
          return name.contains(query);
        }).toList();
        _isSearchPerformed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    var nameIndex = _getHeaderIndex(requiredHeaders['name']!) ?? 0;
    var phoneIndex = _getHeaderIndex(requiredHeaders['phone']!) ?? 1;
    var rankIndex = _getHeaderIndex(requiredHeaders['rank']!) ?? 2;

    return Scaffold(
      appBar: AppBar(
        title: Text("Fort Police Contact Details"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: 'Search by Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Center(
                  child: ElevatedButton(
                    onPressed: _performSearch,
                    child: IconButton(
                      onPressed: _performSearch,
                      icon: Icon(Icons.search, color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple.shade900,
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isSearchPerformed
                ? (_filteredData.isEmpty
                    ? Center(
                        child: Text('No results found',
                            style: TextStyle(fontSize: 18)),
                      )
                    : ListView.builder(
                        itemCount: _filteredData.length,
                        itemBuilder: (_, index) {
                          return Card(
                            margin: const EdgeInsets.all(3),
                            child: ListTile(
                              title: Text('${_filteredData[index][nameIndex]}'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('${_filteredData[index][phoneIndex]}'),
                                  Text(
                                    '${_filteredData[index][rankIndex]}',
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.phone),
                                onPressed: () => _launchPhoneCall(
                                    _filteredData[index][phoneIndex]
                                        .toString()),
                              ),
                            ),
                          );
                        },
                      ))
                : Center(
                    child: Text(
                      'Search for contacts',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
