import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Person Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
              headers.length,
              (index) => _buildDetailRow(
                  headers[index], personData[index].toString())),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
