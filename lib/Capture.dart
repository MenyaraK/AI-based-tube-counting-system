// capture.dart

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CapturePage extends StatefulWidget {
  final String captureImageUrl;
  final String token;

  CapturePage({required this.captureImageUrl, required this.token});

  @override
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  String? _capturedImageUrl;

  @override
  void initState() {
    super.initState();
    // No need to fetch again, we already have the URL.
    _capturedImageUrl = widget.captureImageUrl;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Captured Image"),
        centerTitle: true,
        backgroundColor: Colors.red,
      ),
      body: Center(
        child: _capturedImageUrl != null
            ? Image.network(_capturedImageUrl!)
            : CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
              ),
      ),
    );
  }
}
