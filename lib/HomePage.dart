import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Video.dart';

class BillPage extends StatefulWidget {
  final String token;
  final String deviceIP;
  final String deviceId;
  final String apiParameter;
  final String userId;

  BillPage({
    required this.token,
    required this.deviceIP,
    required this.deviceId,
    required this.apiParameter,
    required this.userId,
  });

  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  List<dynamic> _bills = [];
  String _selectedBillId = "";
  List<String> _selectedQt = [];
  bool _dataLoaded = false; // To check if the data is loaded
  List<TextEditingController> _controllers = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(
        Uri.parse('http://196.179.229.162:8000/v0.1/delivery_order/all'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _bills = List<dynamic>.from(data);
          _dataLoaded = true;
          if (_bills.isNotEmpty) {
            _selectedBillId = _bills[0]['DocEntry'].toString();
            // Initialize the selectedQt based on the first bill as a default
            _selectedQt = _bills.first['delivery_order_lines']
                .map((line) => line['initial_qt'].toString())
                .toList()
                .cast<String>();

            // Also initialize the controllers based on _selectedQt for the first bill
            _controllers = List.generate(_selectedQt.length,
                (index) => TextEditingController(text: _selectedQt[index]));
          }
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Widget buildDropDown() {
    return DropdownButton<String>(
      value: _selectedBillId,
      hint: Text('Veuillez choisir un BL'),
      items: _bills.map((bill) {
        return DropdownMenuItem<String>(
          value: bill['DocEntry'].toString(),
          child: Text('${bill['DocEntry']} - ${bill['DocDate']}'),
        );
      }).toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedBillId = value!;
          final selectedBill = _bills.firstWhere(
              (bill) => bill['DocEntry'].toString() == _selectedBillId,
              orElse: () => {});
          if (selectedBill != null &&
              selectedBill['delivery_order_lines'] != null) {
            _selectedQt = selectedBill['delivery_order_lines']
                .map((line) => line['initial_qt'].toString())
                .toList()
                .cast<String>();
          } else {
            _selectedQt = [];
          }
          _controllers = List.generate(_selectedQt.length,
              (index) => TextEditingController(text: _selectedQt[index]));
        });
      },
    );
  }

  Widget buildGrid() {
    final selectedBill = _bills.firstWhere(
        (bill) => bill['DocEntry'].toString() == _selectedBillId,
        orElse: () => {});
    final List<dynamic> billLines = selectedBill['delivery_order_lines'] ?? [];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columns: [
          DataColumn(label: Text('DocEntry')),
          DataColumn(label: Text('ItemCode')),
          DataColumn(label: Text('type')),
          DataColumn(label: Text('initial_qt')),
          DataColumn(label: Text('selected_qt')),
        ],
        rows: billLines.map((line) {
          return DataRow(cells: [
            DataCell(Text(line['DocEntry'].toString())),
            DataCell(Text(line['ItemCode'].toString())),
            DataCell(Text(line['type'].toString())),
            DataCell(Text(line['initial_qt'].toString())),
            DataCell(TextFormField(
              controller: billLines.indexOf(line) < _controllers.length
                  ? _controllers[billLines.indexOf(line)]
                  : TextEditingController(),
              onChanged: (value) {
                setState(() {
                  int index = billLines.indexOf(line);
                  if (index >= 0 && index < _selectedQt.length) {
                    _selectedQt[index] = value;
                  }
                });
              },
            )),

// New Cell
          ]);
        }).toList(),
      ),
    );
  }

  void _navigateToVideoPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LiveStream(
          device_id: widget.deviceId,
          token: widget.token,
          apiParameter: widget.apiParameter,
          selectedQt: _selectedQt,
          deviceIP: widget.deviceIP,
          userId: widget.userId,
          selectedBill: _selectedBillId,
          BillsList: _bills,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Liste de BL')),
      body: Center(
        child: Column(
          children: [
            if (!_dataLoaded)
              CircularProgressIndicator() // Show a loading indicator while fetching data
            else
              Expanded(
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    Text('Liste de BL'),
                    buildDropDown(),
                    SizedBox(height: 20),
                    Expanded(child: buildGrid()),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: _navigateToVideoPage,
              child: Text('Go to Video Page'),
            ),
          ],
        ),
      ),
    );
  }
}
