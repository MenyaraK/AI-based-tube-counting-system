// OutputPage

import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class OutputPage extends StatefulWidget {
  final String captureId;
  final String token;

  OutputPage({
    required this.captureId,
    required this.token,
  });

  @override
  _OutputPageState createState() => _OutputPageState();
}

class _OutputPageState extends State<OutputPage> {
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    fetchOutputImage();
  }

  Future<void> fetchOutputImage() async {
    final url = Uri.parse(
        'http://196.179.229.162:8000/v0.1/captures/output/${widget.captureId}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Output Image"),
      ),
      body: Center(
        child: _imageBytes != null
            ? Image.memory(_imageBytes!)
            : CircularProgressIndicator(),
      ),
    );
  }
}
