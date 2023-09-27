import 'package:flutter/material.dart';

class RetourOutput extends StatefulWidget {
  final List<double> predictedOutputs; // A list of predicted outputs
  final String captureImageId;
  final String device_id;
  final String token;
  final String apiParameter;
  final List<String> selectedQt;
  final String deviceIP;
  final String userId;
  final String selectedBill;
  final List<dynamic> BillsList;

  RetourOutput({
    required this.predictedOutputs,
    required this.captureImageId,
    required this.device_id,
    required this.token,
    required this.apiParameter,
    required this.selectedQt,
    required this.deviceIP,
    required this.userId,
    required this.selectedBill,
    required this.BillsList,
  });

  @override
  _RetourOutputState createState() => _RetourOutputState();
}

class _RetourOutputState extends State<RetourOutput> {
  List<int> resultCalculated =
      []; // Store the calculated result for each bill line
  List<String> _selectedQt = [];
  String? _currentSelectedBill;

  @override
  void initState() {
    super.initState();
    _currentSelectedBill = widget.selectedBill;
    calculateResults();
  }

  // A method to calculate the result for each bill line based on the predicted outputs
  void calculateResults() {
    for (var billLine in widget.BillsList) {
      int count = 0;
      double typeValue = 0.0; // default value

      if (billLine['type'] != null) {
        typeValue = billLine['type'].toDouble();
      } else {
        print('bill line null');
      }

      double upperLimit =
          typeValue + (0.15 * typeValue); // 15% more than typeValue

      for (double x in widget.predictedOutputs) {
        double convertedValue =
            x * 100; // Convert predicted output from m to cm
        if (convertedValue >= typeValue && convertedValue <= upperLimit) {
          count++;
        }
      }

      resultCalculated.add(count);
    }
  }

  Widget buildGrid() {
    final selectedBill = widget.BillsList.firstWhere(
        (bill) => bill['DocEntry'].toString() == _currentSelectedBill,
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
          DataColumn(label: Text('Expected Output')),
        ],
        rows: billLines.asMap().entries.map((entry) {
          int index = entry.key;
          var line = entry.value;
          return DataRow(cells: [
            DataCell(Text(line['DocEntry'].toString())),
            DataCell(Text(line['ItemCode'].toString())),
            DataCell(Text(line['type'].toString())),
            DataCell(Text(line['initial_qt'].toString())),
            DataCell(Text(
                widget.selectedQt[index])), // Displaying selected_qt as Text
            DataCell(Text(resultCalculated[index]
                .toString())), // Expected Output from calculated result
          ]);
        }).toList(),
      ),
    );
  }

  Widget buildDropDown() {
    return DropdownButton<String>(
      value: _currentSelectedBill,
      hint: Text('Veuillez choisir un BL'),
      items: widget.BillsList.map(
        (bill) => DropdownMenuItem<String>(
          value: bill['DocEntry'].toString(),
          child: Text('${bill['DocEntry']} - ${bill['DocDate']}'),
        ),
      ).toList(),
      onChanged: (String? value) {
        setState(() {
          _currentSelectedBill = value!;
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Retour Output"),
      ),
      body: Center(
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
    );
  }
}
