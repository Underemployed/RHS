import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
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
  Map<String, int> _headerIndices = {};

  // Required headers
  final requiredHeaders = {
    'name': ['name', 'person name', 'full name', 'fullname', 'contact name'],
    'photo': ['photo', 'image', 'picture', "img"],
    'address': ['address', 'location', "map"],
    'area': ['area', 'zone', 'region']
  };

  // Pagination
  int _currentPage = 1;
  final int _itemsPerPage = 10;

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

  void _loadExcel() async {
    try {
      final bytes = await rootBundle.load('assets/data/wanderer.xlsx');
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
        _allData = listData;
        var areaIndex = _getHeaderIndex(requiredHeaders['area']!)!;
        _uniqueAreas = _allData
            .map((row) => row[areaIndex].toString())
            .where((area) => area.isNotEmpty)
            .toSet()
            .toList();
        _filteredData = _allData;
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

  void _filterByArea(String? area) {
    setState(() {
      _selectedArea = area;
      _currentPage = 1;

      if (area == null) {
        _filteredData = _allData;
      } else {
        var areaIndex = _getHeaderIndex(requiredHeaders['area']!)!;
        _filteredData = _allData
            .where((row) =>
                row[areaIndex].toString().trim().toLowerCase() ==
                area.toString().trim().toLowerCase())
            .toList();
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
                    var nameIndex = _getHeaderIndex(requiredHeaders['name']!)!;
                    var photoIndex =
                        _getHeaderIndex(requiredHeaders['photo']!)!;
                    var addressIndex =
                        _getHeaderIndex(requiredHeaders['address']!)!;

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
                                            wanderer[photoIndex].toString()),
                                      ),
                                    ),
                                  );
                                },
                                child: Image.network(
                                  _convertDriveImageLink(
                                      wanderer[photoIndex].toString()),
                                  width: 200,
                                  fit: BoxFit.fitWidth,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Icon(Icons.person, size: 100);
                                  },
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                wanderer[nameIndex]?.toString() ?? 'Unknown',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(wanderer[addressIndex]?.toString() ??
                              'No Address'),
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
