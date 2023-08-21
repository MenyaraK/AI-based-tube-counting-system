import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BillPage extends StatefulWidget {
  final String token;
  final String deviceIP; // New parameter

  BillPage({required this.token, required this.deviceIP});
  @override
  _BillPageState createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  List<dynamic> _bills = [];
  String _selectedBillId = "";

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
          if (_bills.isNotEmpty) {
            _selectedBillId = _bills[0]['DocEntry'].toString();
          }
        });
      } else {
        throw Exception('Failed to load data');
      }
    } catch (e) {
      // Handle error, show error message, etc.
      print('Error fetching data: $e');
    }
  }

  Widget buildDropDown() {
    return DropdownButton<String>(
      value: _selectedBillId,
      hint: Text('Veuillez choisir un BL'),
      items: _bills
          .map(
            (bill) => DropdownMenuItem<String>(
              value: bill['DocEntry'].toString(),
              child: Text('${bill['DocEntry']} - ${bill['DocDate']}'),
            ),
          )
          .toList(),
      onChanged: (String? value) {
        setState(() {
          _selectedBillId = value!;
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
          DataColumn(label: Text('initial_qt')),
          DataColumn(label: Text('selected_qt')),
        ],
        rows: billLines.map((line) {
          return DataRow(
            cells: [
              DataCell(Text(line['DocEntry'].toString())),
              DataCell(Text(line['ItemCode'].toString())),
              DataCell(Text(line['initial_qt'].toString())),
              DataCell(
                TextFormField(
                  initialValue: line['selected_qt'].toString(),
                  onChanged: (value) {
                    setState(() {
                      line['selected_qt'] = value;
                    });
                  },
                ),
              ),
            ],
          );
        }).toList(),
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
            if (_bills.isEmpty)
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
          ],
        ),
      ),
    );
  }
}
