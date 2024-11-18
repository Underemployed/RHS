import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

class WandererScreen extends StatefulWidget {
  const WandererScreen({Key? key}) : super(key: key);

  @override
  _WandererScreenState createState() => _WandererScreenState();
}

class _WandererScreenState extends State<WandererScreen> {
  List<List<dynamic>> _allData = [];
  List<List<dynamic>> _filteredData = [];
  List<String> _uniqueAreas = [];
  String? _selectedArea;

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

  @override
  void initState() {
    super.initState();
    _loadCSV();
  }

  void _loadCSV() async {
    final rawData = await rootBundle.loadString("assets/data/wanderer.csv");
    List<List<dynamic>> listData = const CsvToListConverter().convert(rawData);

    // Remove header row
    listData.removeAt(0);

    setState(() {
      _allData = listData;
      _uniqueAreas = _allData.map((row) => row[3].toString()).toSet().toList();
    });
  }

  void _filterByArea(String? area) {
    setState(() {
      _selectedArea = area;
      _currentPage = 1;

      if (area == null) {
        _filteredData = _allData;
      } else {
        _filteredData = _allData.where((row) => row[3] == area).toList();
      }
    });
  }

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

  List<List<dynamic>> _getPaginatedData() {
    int startIndex = (_currentPage - 1) * _itemsPerPage;
    int endIndex = startIndex + _itemsPerPage;

    return _filteredData.length > endIndex
        ? _filteredData.sublist(startIndex, endIndex)
        : _filteredData.sublist(startIndex);
  }

  int get _totalPages => (_filteredData.length / _itemsPerPage).ceil();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wanderers'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Area Dropdown
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              isExpanded: true,
              hint: Text('Select Area'),
              value: _selectedArea,
              items: _uniqueAreas.map((area) {
                return DropdownMenuItem(
                  value: area,
                  child: Text(area),
                );
              }).toList(),
              onChanged: _filterByArea,
            ),
          ),

          // Table Title
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              _selectedArea != null
                  ? 'Wanderers in ${_selectedArea!}'
                  : 'All Wanderers',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),

          // Wanderer Table
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.grey.shade300),
                columnWidths: {
                  0: FlexColumnWidth(1),
                  1: FlexColumnWidth(2),
                },
                children: [
                  // Table Header
                  TableRow(
                    decoration: BoxDecoration(color: Colors.grey.shade100),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child:
                            Text('Name & Photo', textAlign: TextAlign.center),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text('Address', textAlign: TextAlign.center),
                      ),
                    ],
                  ),
                  // Table Rows
                  ..._getPaginatedData().map((wanderer) {
                    return TableRow(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          FullScreenImageViewer(
                                        imageUrl: _convertDriveImageLink(
                                            wanderer[1].toString()),
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  _convertDriveImageLink(
                                      wanderer[1].toString()),
                                  width: 200,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person, size: 100);
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                wanderer[0]?.toString() ?? 'Unknown',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(wanderer[2]?.toString() ?? 'No Address'),
                        ),
                      ],
                    );
                  }).toList(),
                ],
              ),
            ),
          ),

          // Pagination Controls
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: _currentPage > 1
                      ? () => setState(() => _currentPage--)
                      : null,
                ),
                Text('Page $_currentPage of $_totalPages'),
                IconButton(
                  icon: Icon(Icons.arrow_forward),
                  onPressed: _currentPage < _totalPages
                      ? () => setState(() => _currentPage++)
                      : null,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FullScreenImageViewer extends StatelessWidget {
  final String imageUrl;

  const FullScreenImageViewer({Key? key, required this.imageUrl})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4,
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error_outline,
                      size: 50, color: Colors.white);
                },
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
