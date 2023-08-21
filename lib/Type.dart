import 'package:flutter/material.dart';
import 'devicePage.dart';
import 'package:http/http.dart' as http;

class MyTypePage extends StatefulWidget {
  final String token;

  MyTypePage({required this.token});

  @override
  _MyTypePageState createState() => _MyTypePageState();
}

class _MyTypePageState extends State<MyTypePage> {
  Widget buildSection(BuildContext context, String title, String imagePath,
      String apiParameter) {
    return Column(
      children: [
        SizedBox(height: 20), // For spacing
        Text(
          title,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Divider(
            color: Colors.grey,
            thickness: 1,
          ),
        ),
        SizedBox(height: 10),
        GestureDetector(
          onTap: () {
            // Navigate to the DevicePage when this image is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DevicePage(
                  token: widget.token, // Accessing token through widget.token
                  title: title,
                  apiParameter:
                      apiParameter, // Passing the apiParameter to the next page
                ),
              ),
            );
          },
          child: Container(
            width: 150,
            height: 100,
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(height: 20), // For spacing
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Type")),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              buildSection(context, "Tubes en PVC", "assets/images/img1.png",
                  "Tube_GOC"),
              buildSection(
                  context, "Tubes en Aluminium", "assets/images/img2.png", ""),
              buildSection(
                  context, "Pièce de monnaie", "assets/images/img3.png", ""),
            ],
          ),
        ),
      ),
    );
  }
}
