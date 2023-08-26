import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CapturePage extends StatefulWidget {
  final String captureImageUrl;
  final String token;

  CapturePage({
    required this.captureImageUrl,
    required this.token,
  });

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  String? imageUrl;

  @override
  void initState() {
    super.initState();
    fetchCaptureImage();
  }

  Future<void> fetchCaptureImage() async {
    final url = Uri.parse(widget.captureImageUrl);
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      setState(() {
        imageUrl = response.body;
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
        child: imageUrl != null
            ? Image.network(imageUrl!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
