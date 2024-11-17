import 'package:csv/csv.dart';
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
  List<String> _headers = [];
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchPerformed = false;

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    final rawData = await rootBundle.loadString("assets/data/contact.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    setState(() {
      // First row is headers
      _headers = listData[0].map((header) => header.toString().trim()).toList();

      // Data starts from second row
      _data = listData;
      _filteredData = listData.sublist(1);
    });
  }

  // Launch phone number
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

  void _performSearch() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        _isSearchPerformed = false;
        _filteredData = [];
      } else {
        _filteredData = _data.sublist(1).where((row) {
          // search by name
          String name = row[0].toString().toLowerCase();
          // String phoneNumber = row[1].toString().toLowerCase();

          return name.contains(query);
          // || phoneNumber.contains(query);
        }).toList();

        _isSearchPerformed = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Fort Police Contact Details"),
      ),
      body: _headers.isEmpty
          ? Center(child: CircularProgressIndicator())
          : Column(
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
                      SizedBox(width: 8), // Add some horizontal spacing
                      Center(
                        child: ElevatedButton(
                          onPressed: _performSearch,
                          child: IconButton(
                            onPressed: _performSearch,
                            icon: Icon(
                              Icons.search,
                              color: Colors.white,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple.shade900,
                            padding: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
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
                              child: Text(
                                'No results found',
                                style: TextStyle(fontSize: 18),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _filteredData.length,
                              itemBuilder: (_, index) {
                                return Card(
                                  margin: const EdgeInsets.all(3),
                                  child: ListTile(
                                    title: Text(
                                        '${_filteredData[index][0]}'), // Name
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            '${_filteredData[index][1]}'), // Phone
                                        Text(
                                          '${_filteredData[index][2]}', // Rank
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
                                          _filteredData[index][1].toString()),
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
