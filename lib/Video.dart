import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
  String _url = "http://192.168.1.30/";
  String? _capturedImageUrl;

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
      return json.decode(response.body);
    } else if (response.statusCode == 422) {
      print("Validation Error: ${response.body}");
      throw Exception('Validation Error');
    } else {
      throw Exception('Failed to start streaming');
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
      "workflow": "YOUR_WORKFLOW_VALUE",
      "user_id": "YOUR_USER_ID_VALUE",
    });

    final response = await http.post(url, headers: headers, body: body);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to order capture');
    }
  }

  Future<String> getCapture(String captureId) async {
    final url = Uri.parse(
        'http://196.179.229.162:8000/v0.1/captures/original/$captureId');
    final headers = {
      'Authorization': 'Bearer ${widget.token}',
    };

    final response = await http.get(url, headers: headers);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get capture');
    }
  }

  void _capture() async {
    final captureResponse = await orderCapture();

    if (captureResponse['id'] != null) {
      final capturedImage = await getCapture(captureResponse['id']);
      setState(() {
        _capturedImageUrl = capturedImage;
      });
    } else {
      print("Error in capturing image");
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
              _capturedImageUrl != null
                  ? Image.network(_capturedImageUrl!)
                  : Container(),
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
