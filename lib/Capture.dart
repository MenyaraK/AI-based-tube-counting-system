import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'OutputPage.dart';

class CapturePage extends StatefulWidget {
  final String captureImageId;
  final String token;

  CapturePage({
    required this.captureImageId,
    required this.token,
  });

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    fetchCaptureImage();
  }

  Future<void> fetchCaptureImage() async {
    final url = Uri.parse(
        'http://196.179.229.162:8000/v0.1/captures/original/${widget.captureImageId}');
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
      print("Failed to fetch capture image. Response: ${response.body}");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Captured Image"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _imageBytes != null
                ? Image.memory(_imageBytes!)
                : CircularProgressIndicator(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.red),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => OutputPage(
                          captureId: widget.captureImageId,
                          token: widget.token,
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(primary: Colors.green),
                  child: Text("Validate"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
