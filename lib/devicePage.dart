import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'HomePage.dart';
import 'Video.dart';

class DevicePage extends StatefulWidget {
  final String token;
  final String title;
  final String apiParameter;

  DevicePage(
      {required this.token, required this.title, required this.apiParameter});

  @override
  _DevicePageState createState() => _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  Future<List<dynamic>> fetchDevices() async {
    final url = Uri.parse('http://196.179.229.162:8000/v0.1/devices/all');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to fetch devices');
    }
  }

  Map<String, bool> checkboxValues =
      {}; // Store the checked status for each device ID

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${widget.title} Devices')),
      body: FutureBuilder<List<dynamic>>(
        future: fetchDevices(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            final deviceList = snapshot.data;

            // Initialize checkbox values for each device (only once)
            if (checkboxValues.isEmpty) {
              for (var device in deviceList!) {
                checkboxValues[device['id']] = false;
              }
            }

            return Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: deviceList!.length,
                    itemBuilder: (context, index) {
                      final device = deviceList[index];
                      return CheckboxListTile(
                        value: checkboxValues[device['id']],
                        onChanged: (bool? newValue) {
                          setState(() {
                            checkboxValues[device['id']] = newValue!;
                          });
                        },
                        title: Text('Device ID: ${device['id']}'),
                        subtitle: Text('IP: ${device['ip']}'),
                        secondary: Icon(Icons.lightbulb,
                            color: device['status'] == 'ACTIVE'
                                ? Colors.green
                                : Colors.red),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    List<Map<String, dynamic>> selectedDevices = [];
                    checkboxValues.forEach((key, value) {
                      if (value) {
                        // If the checkbox is checked
                        final device = deviceList!
                            .firstWhere((device) => device['id'] == key);
                        selectedDevices.add(device);
                      }
                    });

                    // Check if any device was selected
                    if (selectedDevices.isEmpty) {
                      final snackBar = SnackBar(
                        content: Text('You must select a device'),
                        duration: Duration(seconds: 3),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LiveStream(
                            token: widget.token,
                            apiParameter: widget.apiParameter,
                            device_id: selectedDevices[0][
                                'id'], // Passing the first selected device's ID
                          ),
                        ),
                      );
                    }
                  },
                  child: Text("Go To Live Stream"),
                ),
              ],
            );
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
