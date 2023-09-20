import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'capture.dart';
import 'package:flutter/widgets.dart';

class LiveStream extends StatefulWidget {
  final String device_id;
  final String token;
  final String apiParameter;
  final List<String> selectedQt; // new parameter
  final String deviceIP;
  final String userId;
  final String selectedBill;
  final List<dynamic> BillsList;

  LiveStream({
    required this.device_id,
    required this.token,
    required this.apiParameter,
    required this.selectedQt,
    required this.deviceIP, // new parameter
    required this.userId,
    required this.selectedBill,
    required this.BillsList,
  });

  @override
  _LiveStreamState createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> with WidgetsBindingObserver {
  VlcPlayerController? _liveController;
  static const String BASE_URL = "http://196.179.229.162:8000";
  String _url = "$BASE_URL/";
  bool isLoading = false; // <-- New variable to manage the loading state
  Map<String, dynamic>? captureResponse;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    startStreaming(widget.device_id).then((response) {
      setState(() {
        _url =
            "http://${response['streaming_ip']}:${response['streaming_port']}/";
        _liveController = VlcPlayerController.network(
          _url,
          options: VlcPlayerOptions(),
        );
      });
    }).catchError((error) {
      print("Error starting streaming: $error");
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this); //
    super.dispose();
    WidgetsBinding.instance?.removeObserver(this);
  }

  // The function that observes app lifecycle changes
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
        _stopStreaming(); // Stop streaming when the app goes to background
        break;
      case AppLifecycleState.resumed:
        startStreaming(widget.device_id).catchError((error) {
          print("Error starting streaming on resume: $error");
        }); // Start streaming when the app comes back to foreground
        break;
      default:
        break;
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

  Future<Map<String, dynamic>> startStreaming(String deviceId) async {
    final url = Uri.parse('http://196.179.229.162:8000/v0.1/streaming/start');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    final body = jsonEncode({'device_id': deviceId});
    final response = await http.post(url, headers: headers, body: body);

    print('Server Response to Start Streaming: ${response.body}' + deviceId);

    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      return responseBody;
    } else {
      throw Exception('Failed to order capture. Response: ${response.body}');
    }
  }

  Future<Map<String, dynamic>> orderCapture() async {
    final url =
        Uri.parse('http://196.179.229.162:8000/v0.1/captures/order/add');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    final body = jsonEncode({
      "delivery_id": 0,
      "device_id": widget.device_id,
      "workflow": "hough_to_generic_tube_count_real",
      "user_id": widget.userId,
    });

    final response = await http
        .post(url, headers: headers, body: body)
        .timeout(Duration(seconds: 40), onTimeout: () {
      throw Exception('HTTP request timed out');
    });

    if (response.statusCode == 201) {
      print('Capture response: ${response.body}');
      return json.decode(response.body);
    } else {
      throw Exception('Failed to order capture');
    }
  }

  void _capture() async {
    setState(() {
      isLoading = true; // <-- Start loading state
    });
    try {
      final response = await orderCapture();
      if (response['original_image'] != null) {
        print("Original Image URL: ${response['original_image']}");
        // Show a SnackBar with the original_image value

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CapturePage(
                captureImageId: response['original_image'].split('/').last,
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
        print("Error in capturing image or image URL is null.");
      }
    } catch (e) {
      print("Error encountered while ordering the capture: $e");
    } finally {
      setState(() {
        isLoading = false; // <-- End loading state
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _back,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.red,
          title: Text("Live View"),
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              _liveController?.stop();
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.black,
                    style: BorderStyle.solid,
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: SizedBox(
                  width: 400,
                  height: 300,
                  child: _liveController == null
                      ? Center(
                          child: CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                        )
                      : VlcPlayer(
                          controller: _liveController!,
                          aspectRatio: 4 / 3,
                          placeholder: Center(
                            child: CircularProgressIndicator(
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.red),
                            ),
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20), // Provide some spacing
              isLoading
                  ? CircularProgressIndicator()
                  : ElevatedButton.icon(
                      onPressed: _capture,
                      icon: Icon(Icons.camera),
                      label: Text(
                        "Capture",
                        style: TextStyle(fontSize: 22),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _back() async {
    return true;
  }
}
