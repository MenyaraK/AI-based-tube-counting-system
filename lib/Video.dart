import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'capture.dart'; // Import the CapturePage

class LiveStream extends StatefulWidget {
  final String device_id;
  final String token;
  final String apiParameter;

  LiveStream({
    required this.device_id,
    required this.token,
    required this.apiParameter,
  });

  @override
  _LiveStreamState createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  VlcPlayerController? _liveController;
  static const String BASE_URL = "http://196.179.229.162:8000";
  String _url = "$BASE_URL/";
  Map<String, dynamic>? captureResponse;

  @override
  void initState() {
    super.initState();
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

  Future<Map<String, dynamic>> startStreaming(String deviceId) async {
    final url = Uri.parse('http://196.179.229.162:8000/v0.1/streaming/start');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${widget.token}',
    };
    final body = jsonEncode({'device_id': deviceId});
    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);
      print('Server Response from orderCapture: $responseBody');
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
      "workflow": "Tube_GOC",
      "user_id": "Monta99",
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
    try {
      final response = await orderCapture();
      if (response['original_image'] != null) {
        // Show a SnackBar with the original_image value
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Original Image URL: ${response['original_image']}"),
            duration: Duration(seconds: 5),
          ),
        );

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CapturePage(
              // Use BASE_URL here
              captureImageUrl:
                  '$_LiveStreamState.BASE_URL${response['original_image']}',
              token: widget.token,
            ),
          ),
        );
      } else {
        print("Error in capturing image or image URL is null.");
      }
    } catch (e) {
      print("Error encountered while ordering the capture: $e");
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
              ElevatedButton.icon(
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
