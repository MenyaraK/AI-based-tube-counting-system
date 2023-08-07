import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class LiveStream extends StatefulWidget {
  @override
  _LiveStreamState createState() => _LiveStreamState();
}

class _LiveStreamState extends State<LiveStream> {
  late VlcPlayerController _liveController;
  final String _url = "http://192.168.107.72:8080/";

  @override
  void initState() {
    _liveController = VlcPlayerController.network(
      _url,
      options: VlcPlayerOptions(),
    );
    super.initState();
  }

  @override
  void dispose() {
    _liveController
        .dispose(); // Dispose the controller when the widget is removed from the tree
    super.dispose();
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
              onPressed: _back,
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
                    child: VlcPlayer(
                      controller: _liveController,
                      aspectRatio: 4 / 3,
                      placeholder: Container(
                          height: 250,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.red),
                              ),
                            ],
                          )),
                    ),
                  ),
                ),
                ElevatedButton.icon(
                    onPressed: _play,
                    icon: Icon(Icons.play_circle_outline),
                    label: Text(
                      "Capture",
                      style: TextStyle(fontSize: 22),
                    )),
              ],
            ),
          ),
        ));
  }

  Future<bool> _back() async {
    if (_liveController.value.isInitialized) {
      print("Disposing...");
      _liveController
          .stop(); // to ensure disposing of the liveController to free up resources
    }
    return true;
  }

  void _play() {
    if (_liveController.value.isInitialized) {
      _liveController.play();
    }
  }
}
