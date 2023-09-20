import 'dart:convert';
import 'dart:typed_data';
import 'RetourOutput.dart';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'Video.dart';

class OutputPage extends StatefulWidget {
  final String captureImageId;
  final String device_id;
  final String token;
  final String apiParameter;
  final List<String> selectedQt;
  final String deviceIP;
  final String userId;
  final String selectedBill;
  final List<dynamic> BillsList;

  OutputPage({
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
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> with WidgetsBindingObserver {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    fetchOutputImage();
    WidgetsBinding.instance?.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  // This function observes app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached ||
        state == AppLifecycleState.inactive) {
      _stopStreaming(); // Stop streaming when the app goes to background
    }
  }

  Future<void> fetchOutputImage() async {
    final url = Uri.parse(
        'http://196.179.229.162:8000/v0.1/captures/output/${widget.captureImageId}');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      setState(() {
        _imageBytes = response.bodyBytes;
      });
    } else {
      print("Failed to fetch output image. Response: ${response.body}");
    }
  }

  void _navigateToRetourOutput() async {
    print("Initiating _navigateToRetourOutput");
    try {
      // Stop the streaming first
      await _stopStreaming();
      print("Streaming stopped");

      // Continue with your current logic
      final url = Uri.parse(
          'http://196.179.229.162:8000/v0.1/captures/get/${widget.captureImageId}');
      final headers = {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${widget.token}',
      };
      final response = await http.get(url, headers: headers);
      print("Received response: ${response.body}");
      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);
        List<double> predictedOutputs = [];
        if (responseBody['predicted_output'] is String) {
          // Using a regex to find all the floating point numbers in the string.
          var matches = RegExp(r"(\d+\.\d+)")
              .allMatches(responseBody['predicted_output']);
          for (var match in matches) {
            predictedOutputs.add(double.parse(match.group(1)!));
          }
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RetourOutput(
                predictedOutputs: predictedOutputs,
                captureImageId: widget.captureImageId,
                device_id: widget.device_id,
                token: widget.token,
                apiParameter: widget.apiParameter,
                selectedQt: widget.selectedQt,
                deviceIP: widget.deviceIP,
                userId: widget.userId,
                selectedBill: widget.selectedBill,
                BillsList: widget.BillsList),
          ),
        );
      } else {
        print("Error fetching data. Response: ${response.body}");
        // Handle error
      }
    } catch (e) {
      print('Error: $e');
      // you can show the error to the user.
    }
  }

  Future<void> _stopStreaming() async {
    final url = Uri.parse('http://196.179.229.162:8000/v0.1/streaming/stop');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    final body = jsonEncode({
      "device_id": widget.device_id,
    });
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Streaming has stopped"),
        ),
      );
    } else if (response.statusCode == 422) {
      // Handle validation error
      print("Validation Error: ${response.body}");
    } else {
      print("Failed to stop streaming. Response: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    print('Displaying image with captureId: ${widget.captureImageId}');
    return Scaffold(
      appBar: AppBar(
        title: Text("Output Image"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Center(
              child: _imageBytes != null
                  ? Image.memory(_imageBytes!)
                  : CircularProgressIndicator(),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LiveStream(
                              device_id: widget.device_id,
                              token: widget.token,
                              apiParameter: widget.apiParameter,
                              selectedQt: widget.selectedQt,
                              deviceIP: widget.deviceIP,
                              userId: widget.userId,
                              selectedBill: widget.selectedBill,
                              BillsList: widget.BillsList)));
                },
                style: ElevatedButton.styleFrom(primary: Colors.red),
                child: Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: _navigateToRetourOutput,
                style: ElevatedButton.styleFrom(primary: Colors.green),
                child: Text("Validate"),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchOutputImage,
        child: Icon(Icons.refresh),
        tooltip: 'Refresh Image',
      ),
    );
  }
}
