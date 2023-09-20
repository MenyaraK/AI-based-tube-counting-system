import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'video.dart';
import 'OutputPage.dart';
import 'dart:async';

class CapturePage extends StatefulWidget {
  final String captureImageId;
  final String device_id;
  final String token;
  final String apiParameter;
  final List<String> selectedQt;
  final String deviceIP;
  final String userId;
  final String selectedBill;
  final List<dynamic> BillsList;

  CapturePage({
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
  _CapturePageState createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> with WidgetsBindingObserver {
  Uint8List? _imageBytes;
  bool isButtonEnabled = false; // State variable to check if button is enabled
  int countdownTime = 20; // Countdown time in seconds

  @override
  void initState() {
    super.initState();
    fetchCaptureImage();
    WidgetsBinding.instance?.addObserver(this);
    // Start the countdown
    startCountdown();
  }

  startCountdown() {
    Timer.periodic(Duration(seconds: 1), (Timer timer) {
      if (countdownTime == 0) {
        timer.cancel();
        setState(() {
          isButtonEnabled = true; // Enable the button after countdown ends
        });
      } else {
        setState(() {
          countdownTime--;
        });
      }
    });
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

  // The function to stop the streaming
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
      print("Streaming has stopped");
    } else {
      print("Failed to stop streaming. Response: ${response.body}");
    }
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
            isButtonEnabled
                ? SizedBox
                    .shrink() // If the button is enabled, do not show any text
                : Text(
                    'Processing the image... $countdownTime seconds left'), // Show countdown
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
                  onPressed: isButtonEnabled // Check if button is enabled
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OutputPage(
                                captureImageId: widget.captureImageId,
                                device_id: widget.device_id,
                                token: widget.token,
                                apiParameter: widget.apiParameter,
                                selectedQt: widget.selectedQt,
                                deviceIP: widget.deviceIP,
                                userId: widget.userId,
                                selectedBill: widget.selectedBill,
                                BillsList: widget.BillsList,
                              ),
                            ),
                          );
                        }
                      : null,
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
